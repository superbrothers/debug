# My debugging container image

This is a container image which has utilities for common debugging tasks.
You can see which utilities are included in a container image in [Dockerfile](Dockerfile).

## Usage

### On your host

```
docker run -it --rm --net=host --pid=host ghcr.io/superbrothers/debug
```

### Kubernetes

Run a debugging container in your Kubernetes cluster:

```
kubectl run --rm -it debug-$(date +%s) --image=ghcr.io/superbrothers/debug
```

If you like the above command, it is useful to alias the command:

```
alias kdebug='kubectl run --rm -it debug-$(date +%s) --image=ghcr.io/superbrothers/debug'
```

Add an ephemeral debugging container to an already running pod:

```
kubectl debug mypod -it --image=ghcr.io/superbrothers/debug
```

## License

The MIT License
