SafeSignUp
==========

In preparation for planned protests at the RSA Conventions to protest the RSA's contract with the NSA to include a backdoor Random number generator in their BSafe library.


This a successful experiment with write a haskell program where the data is encrypted at Rest.


###Deploying Safe Sign Up

Generate a new OpenSSH key pair

```
ssh-keygen -t rsa
```

Keynames are currently hardcoded. You'll want to your keys to be named "Library" and "Library.pub" "Library.pub" will need to be the same directory as the server.


Running the server

You'll want to put a proxy server in front of the app to handle TLS and to intergrate with your existing site.

Added a section like this to your sites nginx.conf
```
       location /SafeSignUp {

          proxy_pass http://localhost:9001;
          proxy_set_header Host $host;

          # re-write redirects to http as to https, example: /home
          proxy_redirect http:// https://;
      }
      
```

You need to start the Safe Sign up server in a persistant way.

A simple strategy is to start SafeSignUp with nohup, tmux or screen.

A longer term strategy is us your distro's init daemon. like https://stackoverflow.com/questions/11214167/how-to-run-snap-haskell-webapp-in-production

You'll want to start SafeSignUp with the following options. "./SafeSignup --address=127.0.0.1 --port=9001 --no-error-log --no-access-log"


###Decrypting the database

1. You want to scp the state directory to your local machine
2. The private key should be in that directory as "Library"
3. run ./SafeSignupDecrypt