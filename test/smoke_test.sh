#! /usr/bin/env bash
set -eou pipefail

cleanup() {
	echo "*** Clean up"
  docker rm -f "$container_name"
	docker kill "$running_id"
	docker rmi -f "$image_id"
	exit
}

wait_for_ssh_connection() {
  timeout=5
  max_attempts=30
  attempt=1

  echo "Checking for SSH availability on $container_ip:22..."

  while [ $attempt -le $max_attempts ]; do
      # Use nc to check if port 22 is open
      echo "Attempt $attempt of $max_attempts..."
      if nc -z -w $timeout $container_ip 22; then
          echo "SSH is available on $container_ip:22."
          break
      else
          echo "SSH not available yet. Retrying..."
      fi

      attempt=$((attempt+1))
      sleep 1
  done
}

# Always run the cleanup function on script exit (even error!)
trap cleanup INT TERM ERR SIGTERM SIGCHLD

container_name="consist_smoke_test_container"
image_id=$(docker build --rm --force-rm --build-arg ssh_prv_key="$(cat ~/.ssh/id_rsa)" --build-arg ssh_pub_key="$(cat ~/.ssh/id_rsa.pub)" -q - <./test/Dockerfile)
echo "Built docker image: $image_id"
running_id=$(docker run --cap-add SYS_ADMIN --rm -t -d --name "$container_name" -p 22:22 "$image_id")

echo "Waiting for container $running_id to be ready..."
while true; do
	if docker inspect -f '{{ .State.Running }}' "$container_name" | grep -q "true"; then
		echo "Container is ready."
		break
	fi
	sleep 1
	echo $(docker inspect -f '{{ .State.Running }}' "$container_name")
done

container_ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$container_name")

echo "Container IP: $container_ip"

echo "Adding host $container_ip to known_hosts for container"
ssh-keyscan -t rsa "$container_ip" >> ~/.ssh/known_hosts && true

wait_for_ssh_connection

bin/dev up "$container_ip" --consistfile=test/Consistfile.test

cleanup()
