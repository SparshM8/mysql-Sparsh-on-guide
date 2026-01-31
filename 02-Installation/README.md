# MySQL Installation Guide

This guide covers installing MySQL on different operating systems.

## Installation for Windows

1. Download the MySQL Installer from the official MySQL website: https://dev.mysql.com/downloads/installer/
2. Run the installer and follow the on-screen instructions to complete the installation.
3. During the installation process, you can choose the setup type (Developer Default, Server Only, etc.) based on your requirements.
4. Set the root password and configure other settings as needed.
5. Complete the installation and start the MySQL server.

## Installation for Linux (Ubuntu)

1. Update the package index:
   ```bash
   sudo apt update
   ```
2. Install MySQL server:
   ```bash
   sudo apt install mysql-server
   ```
3. Secure the MySQL installation:
   ```bash
   sudo mysql_secure_installation
   ```
4. Follow the prompts to set the root password and configure security settings.
5. Start the MySQL service:
   ```bash
   sudo systemctl start mysql
   ```
6. Enable MySQL to start on boot:
   ```bash
   sudo systemctl enable mysql
   ```

## Installation for macOS

1. Install Homebrew if you haven't already:
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```
2. Update Homebrew:
   ```bash
   brew update
   ```
3. Install MySQL:
   ```bash
   brew install mysql
   ```
4. Start the MySQL service:
   ```bash
   brew services start mysql
   ```
5. Secure the MySQL installation:
   ```bash
   mysql_secure_installation
   ```

## Verification

After installation, verify MySQL is running:

```bash
mysql --version
```

Connect to MySQL:

```bash
mysql -u root -p
```

## Next Steps

Once installed, proceed to [Data Types and Constraints](03-Data-Types-and-Constraints/) to learn about MySQL data types.