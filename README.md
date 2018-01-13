## Debug

```
$ rails runner DeliveryCore.deliver
```

## rails image
Rebuild rails image After you update gem file.  

- in development
```
$ docker-compose build rails
```
```
$ docker tag vagrant_rails yutaf/em-rails
```
```
$ docker push yutaf/em-rails
```

- in production
```
$ docker pull yutaf/em-rails
```
```
$ docker-compose stop
```
```
$ docker-compose up -d
```
