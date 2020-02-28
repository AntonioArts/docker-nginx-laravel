<h2>Laravel app generator for Docker environment</h1>

This image aims to be a solid foundation for building and running Laravel apps

<b>Requirements:</b> Сomposer https://getcomposer.org

<h2>Create a new Laravel project:</h2>

1. `chmod 755 ./install.sh`
2. `./install <dir>`

<h2>Run the app:</h2>

1. `docker build -t appname .`
2. `docker run -p YOUR_PORT:8080 appname`
