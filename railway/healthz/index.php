<?php
header('Content-Type: text/plain');
header('Cache-Control: no-store');

function fail(string $why): void {
    http_response_code(503);
    echo $why, "\n";
    exit;
}

$CONFIG = [];
if (!is_readable('/var/www/html/config/config.php')) {
    fail('config missing');
}
include '/var/www/html/config/config.php';
if (empty($CONFIG['installed'])) {
    fail('not installed');
}
if (!empty($CONFIG['maintenance'])) {
    fail('maintenance mode');
}

$host = $CONFIG['dbhost'] ?? 'localhost';
$port = '5432';
if (preg_match('/^([^:\[\]]+):(\d+)$/', $host, $m)) {
    $host = $m[1];
    $port = $m[2];
}
try {
    $pdo = new PDO(
        sprintf('pgsql:host=%s;port=%s;dbname=%s', $host, $port, $CONFIG['dbname'] ?? ''),
        $CONFIG['dbuser'] ?? '',
        $CONFIG['dbpassword'] ?? '',
        [PDO::ATTR_TIMEOUT => 3, PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
    );
    $pdo->query('SELECT 1');
} catch (Throwable $e) {
    fail('database unreachable');
}
echo "ok\n";
