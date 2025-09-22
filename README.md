<<<<<<< task3-siddhant
# TASK-3: Dockerized Strapi, Postgres, and Nginx

This project sets up a complete, production-ready environment for a Strapi CMS application using Docker and Docker Compose. It includes:

* **Strapi**: The Strapi application container.
* **PostgreSQL**: The database container.
* **Nginx**: A reverse proxy container that exposes the Strapi application on port 80.

All services are connected via a custom Docker bridge network named `strapi-net`.

## Prerequisites

* [Docker](https://www.docker.com/get-started)
* [Docker Compose](https://docs.docker.com/compose/install/)

## File Structure

.
├── docker-compose.yml    # Main compose file for all services
├── nginx/
│   └── nginx.conf        # Nginx configuration for reverse proxy
└── README.md             # This file


*(Note: A `strapi-app` directory will be created automatically on the first run to persist your Strapi application code. A `postgres-data` volume will also be created for database persistence.)*

## Setup and Installation

1.  **Create the Project Files:**
    Create the `docker-compose.yml` file and the `nginx/nginx.conf` file in the structure shown above.

2.  **Important: Update Secrets:**
    Open `docker-compose.yml` and change the following environment variables for the `strapi` service to secure your application:
    * `JWT_SECRET`
    * `ADMIN_JWT_SECRET`


3.  **Build and Run the Containers:**
    From the root directory (where `docker-compose.yml` is located), run the following command:

    ```bash
    docker-compose up -d --build
    ```

    * `up`: Creates and starts the containers.
    * `-d`: Runs the containers in detached mode (in the background).
    * `--build`: Forces Docker to build the images (useful for the Strapi image on first run).

4.  **First-Time Strapi Setup:**
    The very first time you run this, the `strapi` container will:
    * Detect that the `/srv/app` directory (mounted from `./strapi-app`) is empty.
    * Run `strapi new .` to generate a new Strapi project inside the volume.
    * Connect to the `postgres_db` container and set up the database.

    This process can take **2-5 minutes**. You can monitor the progress by running:

    ```bash
    docker-compose logs -f strapi
    ```
