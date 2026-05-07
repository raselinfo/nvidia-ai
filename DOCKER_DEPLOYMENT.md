# Docker Deployment Guide

This guide explains how to run the Free Claude Code proxy server using Docker and Docker Compose.

## Quick Start

### 1. Build and Run with Docker Compose (Recommended)

```bash
docker-compose up -d
```

This will:
- Build the Docker image
- Start the container in detached mode
- Map port 8082 on your host to port 8082 in the container
- Load environment variables from your `.env` file

### 2. Build and Run with Docker

```bash
docker build -t free-claude-code .
docker run -d -p 8082:8082 --name free-claude-code \
  -e NVIDIA_NIM_API_KEY=your_api_key \
  -e MODEL_OPUS=nvidia_nim/meta/llama-3.2-90b-vision-instruct \
  -e MODEL_SONNET=nvidia_nim/meta/llama-3.2-11b-vision-instruct \
  -e MODEL_HAIKU=nvidia_nim/nvidia/llama-3.1-nemotron-nano-vl-8b-v1 \
  -e MODEL=nvidia_nim/meta/llama-3.2-11b-vision-instruct \
  free-claude-code
```

## Accessing the Server

The server will be available at:
- **Local**: http://localhost:8082
- **Network**: http://YOUR_SERVER_IP:8082

### Health Check

```bash
curl http://localhost:8082/health
```

Expected response: `{"status":"healthy"}`

## Using with Claude Code

### Local Network Access

```bash
ANTHROPIC_AUTH_TOKEN="freecc" ANTHROPIC_BASE_URL="http://localhost:8082" claude
```

### Remote Network Access

```bash
ANTHROPIC_AUTH_TOKEN="freecc" ANTHROPIC_BASE_URL="http://YOUR_SERVER_IP:8082" claude
```

## Docker Management Commands

### Check Container Status

```bash
docker ps | grep free-claude-code
```

### View Logs

```bash
docker logs free-claude-code
```

### Stop the Container

```bash
docker-compose down
# or
docker stop free-claude-code
docker rm free-claude-code
```

### Restart the Container

```bash
docker-compose restart
# or
docker restart free-claude-code
```

### Update the Application

```bash
docker-compose down
docker build -t free-claude-code .
docker-compose up -d
```

## Configuration

### Environment Variables

The application reads configuration from your `.env` file. Key variables include:

- `NVIDIA_NIM_API_KEY`: Your NVIDIA NIM API key
- `MODEL_OPUS`, `MODEL_SONNET`, `MODEL_HAIKU`: Model mappings
- `MODEL`: Default model to use

### Port Configuration

To change the exposed port, modify the `ports` mapping in `docker-compose.yml`:

```yaml
ports:
  - "3000:8082"  # Maps host port 3000 to container port 8082
```

Then rebuild and restart:

```bash
docker-compose down
docker-compose up -d
```

## Network Configuration

### Access from Other Devices

To access the server from other devices on your network:

1. Find your server's IP address:
   ```bash
   # On Linux/Mac
   ip addr show
   # or
   ifconfig
   ```

2. Use the IP address in Claude Code:
   ```bash
   ANTHROPIC_AUTH_TOKEN="freecc" ANTHROPIC_BASE_URL="http://192.168.1.XXX:8082" claude
   ```

### Firewall Configuration

Make sure port 8082 is open on your firewall:

```bash
# On Linux (ufw)
sudo ufw allow 8082

# On Linux (iptables)
sudo iptables -A INPUT -p tcp --dport 8082 -j ACCEPT

# On Mac (if using firewall)
# Add port 8082 to your firewall settings
```

## Troubleshooting

### Container Won't Start

Check the logs:
```bash
docker logs free-claude-code
```

Common issues:
- Port 8082 already in use: Change the port mapping in docker-compose.yml
- Missing .env file: Ensure .env exists with proper configuration
- API key issues: Verify your NVIDIA_NIM_API_KEY is valid

### Can't Access from Remote

- Check if container is running: `docker ps`
- Verify port mapping: `docker port free-claude-code`
- Test locally first: `curl http://localhost:8082/health`
- Check firewall settings
- Ensure your network allows connections on port 8082

### High Memory Usage

If the container uses too much memory:
1. Switch to smaller models in your .env file
2. Adjust Docker resource limits in docker-compose.yml:
   ```yaml
   deploy:
     resources:
       limits:
         memory: 2G
   ```

## Production Deployment

For production use, consider:

1. **SSL/TLS**: Use a reverse proxy like Nginx with SSL certificates
2. **Authentication**: Add API key validation beyond `freecc`
3. **Rate Limiting**: Implement rate limiting to prevent abuse
4. **Monitoring**: Add health checks and monitoring
5. **Backup**: Regular backups of configuration and logs

### Example Nginx Configuration

```nginx
server {
    listen 443 ssl;
    server_name your-domain.com;

    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;

    location / {
        proxy_pass http://localhost:8082;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

## Security Notes

- Change `ANTHROPIC_AUTH_TOKEN` from `freecc` to something secure in production
- Use environment variables for sensitive data, don't commit them to version control
- Keep your API keys secure and rotate them regularly
- Consider using Docker secrets for sensitive information

## Docker Architecture

- **Base Image**: python:3.14-slim
- **Package Manager**: uv (fast Python package installer)
- **Server**: Uvicorn with FastAPI
- **Exposed Port**: 8082
- **Network**: bridge network named `claude-network`

## Support

For issues or questions:
- Check container logs: `docker logs free-claude-code`
- Test API endpoint: `curl http://localhost:8082/health`
- Verify environment variables in .env file
- Check network connectivity and firewall settings