<?php

class TestServer extends PHPUnit_Framework_TestCase
{
    public function testHtmlFolderIsOwnedByWebappUser()
    {
        $posix = posix_getpwuid(fileowner('/var/www/html'));
        $this->assertEquals('www-data', $posix['name'], '/var/www/html is not owned by www-data');
    }

    public function testApacheIsRunning()
    {
        $this->assertNotEmpty(`pgrep apache2`, 'apache2 process is not running');
    }

    public function testApacheHasInitDotDScript()
    {
        $this->assertFileExists('/etc/init.d/apache2', '/etc/init.d/apache2 file does not exist');
        $this->assertContains('running', `service apache2 status`, 'service apache2 status did not execute successfully');
    }

    public function testApacheHasUpstartConfig()
    {
        $this->assertFileExists('/etc/init/apache2.conf', '/etc/init/apache2.conf Upstart conf does not exist');
        $this->assertContains('process', `status apache2`, 'status apache2 did not show apache2 as running');
    }

    public function testApacheLogsToVarLogHttpd()
    {
        $this->assertFileExists('/var/log/apache2/error_log');
        $this->assertFileExists('/var/log/apache2/access_log');
        // Send a request to server status and ensure that it registers in the error log
        file_get_contents('http://localhost/');

        $this->assertContains('"GET /', `tail -n 50 /var/log/apache2/access_log`, 'Apache does not appear to be logging access to /var/log/apache2/access_log');
    }

    public function testApacheAllowsHtaccessFiles()
    {
        $contents = file_get_contents('/etc/apache2/apache2.conf');
        $this->assertEquals(
            1,
            preg_match('#<Directory "/var/www/html">.*AllowOverride All.*</Directory>#msU', $contents),
            'apache2.conf does not have an AllowOverride All setting for /var/www/html'
        );
    }

    public function testApacheModRewriteIsEnabled()
    {
        $this->assertContains('rewrite_module', `apachectl -t -D DUMP_MODULES | grep rewrite`, 'mod_rewrite not enabled');
    }

    public function testApacheRunsAsWebappUser()
    {
        $this->assertContains('www-data', `ps aux | grep apache2`, 'Apache is not running as www-data');
    }

    public function testEnvironmentalPhpSettingsArePresent()
    {
        // Ensure settings are expose in super globals
        $this->assertNotNull($_SERVER['PHP_DISPLAY_ERRORS']);
        $this->assertNotNull($_ENV['PHP_DISPLAY_ERRORS']);
        $this->assertNotEmpty(getenv('PHP_DISPLAY_ERRORS'));
    }

    public function testDefaultPhpSettingsArePresent()
    {
        $this->assertEquals(getenv('PHP_MEMORY_LIMIT'), ini_get('memory_limit'));
        $this->assertEquals(getenv('PHP_DATE_TIMEZONE'), ini_get('date.timezone'));
        $this->assertEquals(0, ini_get('html_errors'));
        $this->assertEquals('EGPCS', ini_get('variables_order'));
        $this->assertEquals('/tmp', ini_get('session.save_path'));
        $this->assertEquals(90, ini_get('default_socket_timeout'));
        $this->assertEquals('32M', ini_get('post_max_size'));

        // Boolean check function
        $check = function ($value) { return $value == 'On' ? 1 : ''; };
        $this->assertEquals($check(getenv('PHP_DISPLAY_ERRORS')), ini_get('display_errors'));
        $this->assertEquals($check(getenv('PHP_ALLOW_URL_FOPEN')), ini_get('allow_url_fopen'));
        $this->assertEquals($check(getenv('PHP_ZLIB_OUTPUT_COMPRESSION')), ini_get('zlib.output_compression'));
        $this->assertEquals($check(getenv('PHP_ALLOW_URL_FOPEN')), ini_get('allow_url_fopen'));
        $this->assertEquals($check(getenv('PHP_ALLOW_URL_FOPEN')), ini_get('allow_url_fopen'));
        $this->assertEquals($check(getenv('PHP_ALLOW_URL_FOPEN')), ini_get('allow_url_fopen'));
    }

    public function testDocumentRootIsConfigured()
    {
        $settings = file_get_contents('/opt/elasticbeanstalk/deploy/configuration/containerconfiguration');
        $settings = json_decode($settings, true);

        $actual = $settings['env']['PHP_DOCUMENT_ROOT'];
        $root = trim(str_replace(array('DocumentRoot', '"'), '', `grep -m 1 'DocumentRoot "' /etc/apache2/apache2.conf`));

        if ($actual) {
            $this->assertEquals('/var/www/html' . $_SERVER['PHP_DOCUMENT_ROOT'], $root);
        } else {
            // Check for autodetection?
        }
    }

    public function testKillingApacheWillRestartApache()
    {
        if (isset($_ENV['DO_NOT_KILL_APACHE'])) {
            $this->markTestSkipped('Not attempting to kill apache while using the web interface');
        } else {
            `killall apache2`;
            sleep(1);
            $this->assertNotEmpty(`pgrep apache2`, 'apache2 process did not restart');
        }
    }

    public function testRdsVariablesArePresent()
    {
        if (!getenv('RDS_HOSTNAME')) {
            $this->markTestSkipped('RDS is not installed');
        }

        $this->assertNotEmpty(getenv('RDS_HOSTNAME'));
        $this->assertNotEmpty($_SERVER['RDS_HOSTNAME']);
        $this->assertNotEmpty($_ENV['RDS_HOSTNAME']);
    }

    public function testCanConnectToRds()
    {
        if (!getenv('RDS_HOSTNAME')) {
            $this->markTestSkipped('RDS is not installed');
        }

        $connection = new mysqli(
            getenv('RDS_HOSTNAME'),
            getenv('RDS_USERNAME'),
            getenv('RDS_PASSWORD'),
            getenv('RDS_DB_NAME'),
            getenv('RDS_PORT')
        );

        if ($connection->connect_error) {
            $this->fail('Could not connect to RDS: ' . $connection->connect_error);
        }

        $connection->close();
    }

    public function testOldPhpCfgVarSettingsArePresent()
    {
        $this->assertEquals(getenv('AWS_ACCESS_KEY_ID'), get_cfg_var('aws.access_key'));
        $this->assertEquals(getenv('AWS_SECRET_KEY'), get_cfg_var('aws.secret_key'));

        if (!getenv('RDS_HOSTNAME')) {
            $this->markTestIncomplete('RDS is not installed');
        } else {
            $this->assertEquals(getenv('RDS_HOSTNAME'), get_cfg_var('aws.rds_hostname'));
        }
    }

    public function testComposerIsInstalled()
    {
        $this->assertFileExists('/usr/bin/composer.phar');
    }

    public function testPearIsConfigured()
    {
        $this->assertEquals('/etc/php.ini', trim(`pear config-get php_ini`), 'PEAR php_ini not set');
        $this->assertEquals('1', trim(`pear config-get auto_discover`), 'PEAR auto_discover not set');
    }

    public function testInstallsComposerVendorsWhenComposerPresent()
    {
        if (!file_exists('/var/www/html/composer.json')) {
            $this->markTestSkipped('composer.json not found');
        }

        $this->assertTrue(file_exists('/var/www/html/vendor'), 'Composer did not install any vendors');
    }
}
