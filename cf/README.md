# How To

- run

```bash
packer build cf/packer.json
```

to generate an AMI with cp-board installed. Grab the ami-id and paste it
into the proper place in build.py.

- run

```bash
make build_cf
```

Then upload cf/generate_cf.yml in your favourite way to AWS, and you're done.

## To Do

- Implement API filter function (for a specific team for instance)
- Secure access to API in CF template (make a Parameter for CIDR Range of given
  company)
