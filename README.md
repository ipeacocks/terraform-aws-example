# Terraform templates example

`simple-web`

Is directory where described simple EC2 server in default VPC/subnets.
<br><br>
`subnets-web`

There described creating of new VPC with public and private subnets inside.

<p align="left">
  <img src="_schemes/subnets-web-schema.png" width="600" height="470"/>
</p>

-----
If no additional procedures are exist inside of each dir you can apply them as follow:

```
$ terraform plan
$ terrafrom apply
```
\
Blog post regarding this code (UA lang): https://blog.ipeacocks.info/2018/07/terraform-managing-aws-infrastructure.html
