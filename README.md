# How to Docker

This repo serves as a minimal multi-container Docker application, running a simple Express server and launching a sepparate container for a database (postgres).

## Docker

Docker images and containers make applications more shareable; able to work on any machine, by including in the image everything that's needed to run the app on the container.

To use Docker, you need one `Dockerfile` per image. This file includes instructions for building and running the application. These are the contents of our `Dockerfile`:

    FROM node:22 
    WORKDIR /app

    COPY package*.json ./

    RUN npm install

    COPY . .

    ENV PORT=3000
    EXPOSE 3000

    CMD ["npm", "run" ,"start"]

The server relies on Node, so we import it:

    FROM node:22 

We set the working directory, usually `app`

    WORKDIR /app

We copy into the working directory everything the application needs to be set up. If this were python based, we might copy reqioremetnts.txt to build a virtual environment on the next step, when we isntall the dependencies

    COPY package*.json ./

    RUN npm install

Then we copy everything else teh application needs. Doing it this way speeds up build, by relying on cached layers (instructions) for the intitial setup, and only rebuild on code changes. 

If there is anything we don't want to copy, it should be added in a `.dockerignore` file. It's the same as `.gitignore`.

    COPY . .

We Expsoe the port we will be using: 3000. Then, finally run the app. 

    ENV PORT=3000
    EXPOSE 3000

    # run the app
    CMD ["npm", "run" ,"start"]

why not `RUN npm start`?
RUN happens when building the image, CMD is used to start the container AFTER building.
You can only have one CMD instruction in a Dockerfile, if you add another one it will override the previous one 

Now we go to the terminal, into the project directory, and build the image:

    docker build -t docker_example .

Then run the container, forwarding port 3000, since the container requires it:

    docker run -p 3000:3000 docker_example


## Compose

how to run
docker compose up
docker compose down

Docker compose allows for coordinating separate containers. To acomplish this, `compose.yaml` is required:

    services:
    backend:
        build: .
        ports:
        - "3000:3000"
    db:
        image: postgres:latest 
        environment:
        POSTGRES_USER: user
        POSTGRES_PASSWORD: password
        POSTGRES_DB: mydb
        volumes: # let's db know about the volume
        - db_data:/var/lib/postgresql/data

    volumes:
    db_data:

But what does it do?

    services:
      backend:
      ...
      db:
      ...
      volumes:
      ...


`backend` and `db` represent the containers we want to run. `volumes` creates a shared folder where containers can share data, and that will persist when the container is closed.

    backend:
        build: .
        ports:
        - "3000:3000"

for the `backend` container, `build` points to the Dockerfile, which in this case is in the same directory as compose.yaml. We also declare the ports we will be routing.

    db:
        image: postgres:latest
        environment:
        POSTGRES_USER: user
        POSTGRES_PASSWORD: password
        POSTGRES_DB: mydb
        volumes: # let's db know about the volume
        - db_data:/var/lib/postgresql/data

for the `db` container, we will be borrowing an image file from docker: postgres. Looking at the docker page, it requires some environment variables. We also point it to the volume docker creates.

Having the required files, now head to the working directory and run 

    Docker compose up

To bring it down:

    docker compose down


## Other notes:
index.js starts the server. It therefore must be in package.json as a script:

        "scripts": {
            "start": "node ./src/index.js"
        },

