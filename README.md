# **ping**

```
 ; ./ping http://info.cern.ch/hypertext/WWW/TheProject.html
 > DNS lookup took: 8ms
 > Connecting took: 34ms
 > Request took: 33ms
 > Total time: 76ms

 >> Status: 200
 >> Content length: 2217 bytes

 ; ./ping https://danreev.es/photography
 > DNS lookup took: 6ms
 > Connecting took: 109ms
 >> TLS handshake took: 70ms
 > Request took: 28ms
 > Total time: 144ms

 >> Status: 200
 >> Content length: 548 bytes
```

## Contributing

1. Fork it (<https://github.com/your-github-user/ping/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Dan Reeves](https://github.com/danreeves) - creator and maintainer
