## A Rails base_image using your linux user, RVM and NVM

This image is most useful if you want to experiment easily with different Ruby/Node
versions on development, using RVM and NVM and your normal linux user. So, when 
mounting your project as a volume the image respects the file owner on write.

It is also useful as a base rails image (even though if you care about size/network costs,
you should consider using a smaller image).

If you really like the idea of having the "exact" same development/production
stack, then this might be a good choice for you. As long as you develop only through
this image locally.

**To build any Ruby/Node combination**
```
docker build --build-arg RUBY_VERSION=${RUBY_VERSION} --build-arg NODE_VERSION=${NODE_VERSION} --build-arg USER_UID=${USER_UID} --build-arg USER_GID=${USER_GID} -t rails_base:${RUBY_VERSION}_node-${NODE_VERSION} .
```

**To run a development console**
```
docker-compose run --rm web /bin/bash
```

**Example docker-compose.yml**
```
version: '3.5'

services:
  db:
    image: postgres:11.7
    volumes:
      - ../docker/volumes/db/data:/var/lib/postgresql/data
    environment:
      POSTGRES_PASSWORD: ${DATABASE_PASSWORD}
    ports:
      - "5432:5432"
    restart: always

  web: &app_base
    image: rails_base
    build:
      context: .
      dockerfile: docker/dockerfiles/base/Dockerfile
      args:
        USER_UID: $USER_UID
        USER_GID: $USER_GID
        NODE_VERSION: $NODE_VERSION
        RUBY_VERSION: $RUBY_VERSION
    ports:
      - "3000:3000"
    environment:
      GEM_HOME: '/home/user/.rvm/gems'
      GEM_PATH: '/home/user/.rvm/gems'
      PATH: "/home/user/.rvm/gems/*/bin:/home/user/.rvm/gems/*@global/bin:/home/user/.rvm/rubies/*/bin:/home/user/.rvm/bin:/home/user/.nvm/versions/node/*/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/user/app/bin"
    env_file:
      - .env
    depends_on:
      - db
    volumes:
      - .:/home/user/app
      - ../docker/volumes/gems:/home/user/.rvm/gems
```

**Mounting volumes**

A nice trick is to mount your gems in a persistent volume
so that you don't erase your gems every time you run `docker-compose down`

```
volumes:
      - .:/home/user/app
      - ../docker/volumes/gems:/home/user/.rvm/gems
```
