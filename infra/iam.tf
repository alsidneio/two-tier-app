data "aws_iam_role" "too-many-permssions" {
  name = "too_much_for_EC2_Role"
}

resource "aws_iam_instance_profile" "vm-profile" {
  name = "vm-profile"
  role = data.aws_iam_role.too-many-permssions.name
}