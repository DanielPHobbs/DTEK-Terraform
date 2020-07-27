variable "count" {default = 2} 

resource "azurerm_network_interface" "terraform-CnetFace" {
  count = "${var.count}"
  ...
}

resource "azurerm_virtual_machine" "terraform-test" {
  count = "${var.count}"
  ...
  network_interface_ids = ["${element(azurerm_network_interface.terraform-CnetFace.*.id, count.index)}"]
  ...
}



##########instance.tf:  #########################################################################
resource "aws_key_pair" "terraform-demo" {
  key_name   = "terraform-demo"
  public_key = "${file("terraform-demo.pub")}"
}

resource "aws_instance" "my-instance" {
  count         = "${var.instance_count}"
  ami           = "${lookup(var.ami,var.aws_region)}"
  instance_type = "${var.instance_type}"
  key_name      = "${aws_key_pair.terraform-demo.key_name}"
  user_data     = "${file("install_apache.sh")}"

  tags = {
    Name  = "${element(var.instance_tags, count.index)}"
    Batch = "5AM"
  }
}


#######vars.tf:

variable "ami" {
  type = "map"

  default = {
    "us-east-1" = "ami-04169656fea786776"
    "us-west-1" = "ami-006fce2a9625b177f"
  }
}

variable "instance_count" {
  default = "2"
}

variable "instance_tags" {
  type = "list"
  default = ["Terraform-1", "Terraform-2"]
}

variable "instance_type" {
  default = "t2.nano"
}

variable "aws_region" {
  default = "us-east-1"
}


##########################################################################

