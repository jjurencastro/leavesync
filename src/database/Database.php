<?php
/**
 * Database Connection Handler
 */

class Database {
    private static $instance = null;
    private $connection;

    private function __construct() {
        try {
            $this->connection = new mysqli(
                DB_HOST,
                DB_USER,
                DB_PASSWORD,
                DB_NAME,
                DB_PORT
            );

            if ($this->connection->connect_error) {
                throw new Exception("Connection failed: " . $this->connection->connect_error);
            }

            $this->connection->set_charset("utf8mb4");

            if (!APP_DEBUG) {
                $this->connection->options(MYSQLI_OPT_SSL_VERIFY_SERVER_CERT, false);
            }
        } catch (Exception $e) {
            error_log("Database Connection Error: " . $e->getMessage());
            die("Database connection failed");
        }
    }

    public static function getInstance() {
        if (self::$instance === null) {
            self::$instance = new self();
        }
        return self::$instance;
    }

    public function getConnection() {
        return $this->connection;
    }

    public function query($sql, $params = []) {
        try {
            $stmt = $this->connection->prepare($sql);

            if (!$stmt) {
                throw new Exception("Prepare failed: " . $this->connection->error);
            }

            if (!empty($params)) {
                $types = '';
                foreach ($params as $param) {
                    if (is_int($param)) $types .= 'i';
                    elseif (is_float($param)) $types .= 'd';
                    elseif (is_string($param)) $types .= 's';
                    else $types .= 'b';
                }
                $stmt->bind_param($types, ...$params);
            }

            if (!$stmt->execute()) {
                throw new Exception("Execute failed: " . $stmt->error);
            }

            return $stmt;
        } catch (Exception $e) {
            error_log("Query Error: " . $e->getMessage());
            throw $e;
        }
    }

    public function getResults($sql, $params = []) {
        $stmt = $this->query($sql, $params);
        $result = $stmt->get_result();
        return $result->fetch_all(MYSQLI_ASSOC);
    }

    public function getRow($sql, $params = []) {
        $stmt = $this->query($sql, $params);
        $result = $stmt->get_result();
        return $result->fetch_assoc();
    }

    public function execute($sql, $params = []) {
        $stmt = $this->query($sql, $params);
        return $stmt->affected_rows > 0;
    }

    public function lastInsertId() {
        return $this->connection->insert_id;
    }

    public function close() {
        if ($this->connection) {
            $this->connection->close();
        }
    }

    private function __clone() {}
    private function __wakeup() {}
}
?>
