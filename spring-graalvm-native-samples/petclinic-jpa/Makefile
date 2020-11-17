.PHONY: build

ARTIFACT=petclinic-jpa
VERSION=0.0.1-SNAPSHOT
MAIN_CLASS=com.example.data.redis.RedisApplication
JAR_FILE="$(ARTIFACT)-$(VERSION).jar"

REPO="krisfoster"
GRAAL_VER = "20.2.0"
JAVA_VER = "11"
PWD=$$PWD

$(JAR_FILE):
	rm -rf target
	mkdir -p target/native-image
	echo "Packaging $ARTIFACT with Maven"
	mvn -ntp package > target/native-image/output.txt

build: $(JAR_FILE)

compile-on-docker:
	docker build \
		-f Dockerfile-compile \
		-t krisfoster/pet-clinic-jpa:compile .

build-native-image:
	docker build \
		--compress \
		-f Dockerfile-distroless \
		-t krisfoster/pet-clinic-jpa:ni-distroless-xmx32 .

copy-exe:
	id=$$(docker create $(IMG_NAME))
	docker cp $$id:/ni/ni-app build/target
	docker rm -v $id

build-openjdk: $(JAR_FILE)
	docker build \
		--build-arg JAR_FILE=$(JAR_FILE) \
		--compress \
		-f Dockerfile-openjdk \
		-t krisfoster/pet-clinic-jpa:openjdk .

build-graaljdk: $(JAR_FILE)
	docker build \
		--build-arg JAR_FILE=$(JAR_FILE) \
		--compress \
		-f Dockerfile-graaljdk \
		-t krisfoster/pet-clinic-jpa:graaljdk .

profile:
	mkdir -p reports/native
	docker-compose up --scale petclinic-jpa=4 -d
	sleep 5s
	scripts/load-ni.sh reports/native/
	docker-compose stop

profile-openjdk:
	mkdir -p reports
	docker-compose -f docker-compose.openjdk.yml up -d
	sleep 5s
	scripts/load.sh reports/openjdk/
	docker-compose -f docker-compose.openjdk.yml stop

profile-mac-jit:
	mkdir -p reports/graal-jit
	export PET_PORT=8081
	docker-compose -f docker-compose.mysql.yml up -d
	jid=$$(java -jar ./target/petclinic-jpa-0.0.1-SNAPSHOT.jar &)
	sleep 20s
	scripts/load.sh reports/graal-jit/
	docker-compose -f docker-compose.mysql.yml stop
	kill $$jid


profile-graaljdk:
	mkdir -p report
	docker-compose -f docker-compose.graaljdk.yml up -d
	sleep 5s
	scripts/load.sh reports/openjdk/
	docker-compose -f docker-compose.graaljdk.yml stop

clean:
	rm -rf ./installs

cadvisor:
	VERSION=v0.36.0 # use the latest release version from https://github.com/google/cadvisor/releases
	sudo docker run \
      --volume=/:/rootfs:ro \
      --volume=/var/run:/var/run:ro \
      --volume=/sys:/sys:ro \
      --volume=/var/lib/docker/:/var/lib/docker:ro \
      --volume=/dev/disk/:/dev/disk:ro \
      --publish=8080:8080 \
      --detach=true \
      --name=cadvisor \
      --privileged \
      --device=/dev/kmsg \
      gcr.io/cadvisor/cadvisor:v0.36.0
      @echo "Open localhost:8080 to view cAdvisor"

