# instructions to run the server
FROM node:22 

#Where is the working directory
WORKDIR /app

# Instead of getting the code and then downloading dependencies, we download dep. first
# so that we can cache the layer and speed up builds
# layer caching: if a layer (or line in the Dockerfile) has not changed, it will use the cache
# Copy the package.json and package-lock.json files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code. Important to add node_modules to .dockerignore
COPY . .

#set port environment variable 9-3000?
ENV PORT=3000
EXPOSE 3000

# run the app
CMD ["npm", "run" ,"start"]

# why not RUN npm start?
# RUN happens when building the image, CMD is used to start the container AFTER building
# You can only have one CMD instruction in a Dockerfile, if you add another one it will override the previous one 