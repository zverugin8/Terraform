variable "regions" {
  type = map(string)
  default = {
    "0" = "us-central1"
    "1" = "us-east1"
  }
}

variable "studentname" {
  type        = string
  description = "The student name"
}

variable "studentsurname" {
  type        = string
  description = "The student surename"
}

variable "project" {
  type    = string
  default = "saroka-gc-bootcamp"
}

# variable "subnets" {
#   type = list(string)
# }

