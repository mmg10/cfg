docker pull fnsys/dockhand:latest

docker run -d \
  --name dockhand \
  --restart unless-stopped \
  -p 9999:3000 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v dockhand_data:/app/data \
  fnsys/dockhand:latest
