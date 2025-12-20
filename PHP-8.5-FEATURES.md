# PHP 8.5 Features and Improvements

This document highlights the new features and improvements in PHP 8.5 that are available in this Docker image.

## Major New Features

### 1. Property Hooks

Property hooks provide a way to define getter and setter behavior directly on properties, reducing the need for explicit getter/setter methods.

```php
class User
{
    public string $name {
        set => $value = trim($value);
        get => strtoupper($this->name);
    }
    
    public string $email {
        set {
            if (!filter_var($value, FILTER_VALIDATE_EMAIL)) {
                throw new InvalidArgumentException("Invalid email format");
            }
            $this->email = $value;
        }
    }
}
```

### 2. Asymmetric Visibility

Asymmetric visibility allows different access levels for reading and writing properties.

```php
class BankAccount
{
    public private(set) float $balance;
    
    public function __construct(float $initialBalance) {
        $this->balance = $initialBalance;
    }
    
    public function deposit(float $amount): void {
        $this->balance += $amount;
    }
    
    // balance can be read publicly but only modified privately
}

$account = new BankAccount(100.0);
echo $account->balance;  // Allowed: public read access
$account->balance = 200; // Error: private write access
```

### 3. Deprecated Attribute

The new `#[Deprecated]` attribute allows marking functions, methods, and classes as deprecated with custom messages.

```php
class LegacyCode
{
    #[Deprecated("Use newMethod() instead", "8.5")]
    public function oldMethod(): void
    {
        // Old implementation
    }
    
    public function newMethod(): void
    {
        // New implementation
    }
}
```

### 4. New DOM API

PHP 8.5 introduces a modern DOM API that's more consistent and easier to use.

```php
$dom = new DOMDocument();
$dom->loadHTML('<html><body><div class="content">Hello</div></body></html>');

$elements = $dom->querySelectorAll('.content');
foreach ($elements as $element) {
    echo $element->textContent;
}
```

## Performance Improvements

### 1. Optimized JIT Compilation

The Just-In-Time (JIT) compiler has been further optimized for better performance in CPU-intensive applications.

### 2. Improved Type System

The type system has been enhanced with better type inference and more efficient type checking.

### 3. Memory Usage Optimizations

Several memory usage optimizations have been implemented, reducing the memory footprint of PHP applications.

## Other Improvements

### 1. Enhanced Error Handling

- Better error messages for common mistakes
- More informative stack traces
- Improved exception handling

### 2. Standard Library Additions

- New string manipulation functions
- Additional array functions
- Improved date/time handling

### 3. Developer Experience

- Better debugging capabilities
- Improved reflection API
- Enhanced error reporting

## Migration from PHP 8.4

While PHP 8.5 is largely backward compatible with PHP 8.4, there are a few things to consider:

1. **Extension Compatibility**: Ensure all your PHP extensions are compatible with PHP 8.5
2. **Testing**: Thoroughly test your application after upgrading
3. **Dependencies**: Check that your dependencies support PHP 8.5

## Using PHP 8.5 Features in This Docker Image

This Docker image comes with PHP 8.5.1 and all the necessary extensions to take advantage of these new features. You can start using them immediately in your applications.

### Example Docker Compose Configuration

```yaml
version: '3.8'
services:
  app:
    image: siomkin/8.5-fpm-alpine
    volumes:
      - ./src:/var/www
    environment:
      - TZ=UTC
    # Add your application-specific configuration here
```

### Testing PHP 8.5 Features

You can test PHP 8.5 features using the following commands:

```bash
# Run a container
docker run -it --rm siomkin/8.5-fpm-alpine sh

# Test property hooks
php -r "
class User {
    public string \$name {
        set => \$value = trim(\$value);
        get => strtoupper(\$this->name);
    }
}

\$user = new User();
\$user->name = '  john doe  ';
echo \$user->name;  // Outputs: JOHN DOE
"
```

## Resources

- [PHP 8.5 Release Notes](https://www.php.net/releases/8.5/en.php)
- [PHP 8.5 Migration Guide](https://www.php.net/manual/en/migration85.php)
- [PHP 8.5 New Features](https://wiki.php.net/rfc#php_85)
