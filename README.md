# README

Docker container for Pysangamam Workshop : _Computer Vision through the Ages_.

You can install Docker CE for Linux or MacOS or use dockertools on Windows.

## Importing the Image

Import the image as:

```
cat /path/to/cvi-pysng.gz | docker import  - cvi-pysng
```


Run the image as:

```
docker run --it --name cvi -p 8888:8888 -v /some/mount/:/pysangamam cvi-pysng bash
```

Mounting a volume is optional, but you may find it easier to make changes in files (vim is bundled in the container too).

Now, in your container,

* You can access the bottleneck scripts at `keras-bottlenecks`
* You can run a jupyter notebook for the code snippets:

```
jupyter notebook --ip=0.0.0.0 --allow-root
```

This should redirect to port 8888 (on localhost). If the port is blocked, try another port with the `--port` flag.

## Building the Image

Build the image as:

```
docker build -t cvi-pysng -t p .
```

Run the image as:

```
docker run --it --name cvi -p 8888:8888 -v /some/mount/:/pysangamam cvi-pysng bash
```

The remaining steps are the same.