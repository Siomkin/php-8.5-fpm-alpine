# PHP 8.5 Features and Improvements

This document highlights the new features and improvements in PHP 8.5 that are available in this Docker image.

## Major New Features

### 1. Pipe Operator (`|>`)

The pipe operator chains function calls left-to-right, eliminating deeply nested calls and temporary variables.

```php
$result = "  hello world  "
    |> trim(...)
    |> strtoupper(...)
    |> str_replace(' ', '-', ...);

echo $result; // "HELLO-WORLD"
```

Each callable must accept exactly one required parameter. The result of the left side becomes the argument to the right side.

### 2. `array_first()` and `array_last()`

Native functions to retrieve the first and last values of an array, complementing `array_key_first()` and `array_key_last()` from PHP 7.3.

```php
$items = ['apple', 'banana', 'cherry'];

echo array_first($items); // "apple"
echo array_last($items);  // "cherry"

// Returns null for empty arrays
echo array_first([]); // null

// Works with associative arrays (insertion order)
$map = ['b' => 2, 'a' => 1, 'c' => 3];
echo array_first($map); // 2
echo array_last($map);  // 3
```

### 3. URI Extension

A built-in URI extension provides standards-compliant parsing and normalization following RFC 3986 and the WHATWG URL Standard, replacing the limited `parse_url()` function.

```php
$uri = Uri\Rfc3986Uri::parse("https://user:pass@example.com:8080/path?q=1#frag");

echo $uri->getScheme();   // "https"
echo $uri->getHost();     // "example.com"
echo $uri->getPort();     // 8080
echo $uri->getPath();     // "/path"
echo $uri->getQuery();    // "q=1"
echo $uri->getFragment(); // "frag"
```

### 4. Clone With

Update properties while cloning objects using `clone()` with named arguments.

```php
class Point {
    public function __construct(
        public readonly float $x,
        public readonly float $y,
    ) {}
}

$p1 = new Point(1.0, 2.0);
$p2 = clone($p1, y: 5.0);

echo $p2->x; // 1.0 (preserved)
echo $p2->y; // 5.0 (updated)
```

### 5. `#[\NoDiscard]` Attribute

Warns when a function's return value is silently ignored, helping catch bugs where return values indicate errors or carry important data.

```php
#[\NoDiscard("Check the return value for errors")]
function save(string $data): bool {
    // ...
    return true;
}

save("data"); // Warning: return value of save() is not used
$ok = save("data"); // No warning
```

### 6. Closures in Constant Expressions

Static closures and first-class callables can now be used in constant expressions such as parameter defaults, attribute arguments, and constant initializers.

```php
function process(array $items, Closure $transform = strtoupper(...)) {
    return array_map($transform, $items);
}

process(['hello', 'world']); // ["HELLO", "WORLD"]
```

## Other Improvements

### Error/Exception Handler Getters

New `get_error_handler()` and `get_exception_handler()` functions let you inspect the currently registered handlers.

```php
set_error_handler(function ($errno, $errstr) { /* ... */ });

$handler = get_error_handler();
// Returns the currently set error handler
```

### cURL Improvements

`curl_multi_get_handles()` retrieves all handles currently attached to a multi-handle.

## Migration from PHP 8.4

PHP 8.5 is largely backward compatible with PHP 8.4. Key considerations:

1. **Extension Compatibility**: Ensure all your PHP extensions are compatible with PHP 8.5
2. **Testing**: Thoroughly test your application after upgrading
3. **Dependencies**: Check that your Composer dependencies support PHP 8.5

## Using PHP 8.5 Features in This Docker Image

This Docker image comes with PHP 8.5.4 and all the necessary extensions to take advantage of these new features.

### Example Docker Compose Configuration

```yaml
services:
  app:
    image: siomkin/8.5-fpm-alpine
    volumes:
      - ./src:/var/www
    environment:
      - TZ=UTC
```

### Testing PHP 8.5 Features

```bash
docker run -it --rm siomkin/8.5-fpm-alpine sh

# Test pipe operator
php -r "
\$result = '  hello world  ' |> trim(...) |> strtoupper(...);
echo \$result;  // Outputs: HELLO WORLD
"

# Test array_first / array_last
php -r "
echo array_first([10, 20, 30]);  // 10
echo array_last([10, 20, 30]);   // 30
"
```

## Resources

- [PHP 8.5 Release Announcement](https://www.php.net/releases/8.5/en.php)
- [PHP 8.5 Migration Guide](https://www.php.net/manual/en/migration85.php)
- [PHP 8.5 RFCs](https://wiki.php.net/rfc#php_85)
