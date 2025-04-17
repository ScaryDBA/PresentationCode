## Timescale

docker pull timescale/timescaledb-ha:pg17


docker run -d --name HamShackRadio `
    -p 5432:5432 `
    -e POSTGRES_PASSWORD=*cthulhu1988 `
    -v C:\bu:/var/lib/postgresql/data `
    -e POSTGRES_USER=postgres `
    timescale/timescaledb-ha:pg17


## for cleanup    
docker stop HamShackRadio
docker rm HamShackRadio


## docker compose
# Start the container
docker compose up -d

# View logs
docker compose logs

# Stop the container
docker compose down

# Stop and remove volumes
docker compose down -v


