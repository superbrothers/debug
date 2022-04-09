# My debugging container image

This is a container image which has utilities for common debugging tasks.
You can see which utilities are included in a container image in [Dockerfile](Dockerfile).

## Usage

**On your host:**

```
docker run -it --rm --net=host --pid=host ghcr.io/superbrothers/debug
```

**Kubernetes:**

```
kubectl debug mypod -it --image=ghcr.io/superbrothers/debug
```

## License

The MIT License
