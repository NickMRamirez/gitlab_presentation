# Wait for Gitlab server to become available...
until $(curl --output /dev/null --silent --head --fail $CI_SERVER_URL ); do
    printf '.'
    sleep 5
done

gitlab-runner unregister --name $RUNNER_NAME 2>/dev/null
gitlab-runner register --non-interactive
gitlab-runner run --user=gitlab-runner --working-directory=/home/gitlab-runner