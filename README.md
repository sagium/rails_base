## A Rails base_image using your linux user, RVM and NVM

This image is most useful if you want to experiment easily with different Ruby/Node
versions on development, using RVM and NVM and your normal linux user. So, when 
mounting your project as a volume the image respects the file owner on write.

It is also useful as a base rails image (even though if you care about size/network costs,
you should consider using a smaller image). After all, the only solid way to cut networking
costs is by having a dedicated machine for image building. Believe me, there are only a few
image layers that will have to change upon consequent builds.

If you really like the idea of having the "exact" same development/production
stack, then this might be a good choice for you. As long as you develop only through
this image locally.

**To build any Ruby/Node combination**
```
echo "ruby-2.7.1" > .ruby-version
echo "10.15.2" > .nvmrc

USER_UID=$(id -u) USER_GID=$(id -g) .github/workflows/helpers/build_image.sh 
```

**To run a development console**
```
docker-compose run --rm web /bin/bash -l
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
    image: sagium2/rails_base:ruby-2.7.1_node-10.15.2
    ports:
      - "3000:3000"
    environment:
      PATH: "/home/user/.rvm/gems/*/bin:/home/user/.rvm/gems/*@global/bin:/home/user/.rvm/rubies/*/bin:/home/user/.rvm/bin:/home/user/.nvm/versions/node/*/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/user/app/bin"
      WEBPACKER_DEV_SERVER_HOST: webpacker
    env_file:
      - .env
    depends_on:
      - db
      - webpacker
    volumes:
      - .:/home/user/app
      - ../docker/volumes/gems:/home/user/.rvm/gems

  webpacker:
    image: sagium2/rails_base:ruby-2.7.1_node-10.15.2
    ports:
      - '3035:3035'
    environment:
      WEBPACKER_DEV_SERVER_HOST: 0.0.0.0
    command: "/bin/bash -c -l ./bin/webpack-dev-server"
    env_file:
      - .env
    volumes:
      - .:/home/user/app
      - ../docker/volumes/gems:/home/user/.rvm/gems

```

**Mounting volumes**

A nice trick is to mount your gems in a persistent volume
so that you don't erase your gems every time you run `docker-compose down`

```
volumes:
      - ../docker/volumes/gems:/home/user/.rvm/gems
```
