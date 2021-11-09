output "customer_name" {
  value = "skf-cenit"
}


output "github_users" {
  value = {

    "github@skfcenitbycognite.onmicrosoft.com" = {
      "github_account" = "cognite-skfcenit-cicd"
      "org_member"     = "admin"
    }

    "joel.sirefelt@cognitedata.com" = {
      "github_account" = "CogJoel"
      "org_member"     = "member"
    }

    "scott.melhop@cognitedata.com" = {
      "github_account" = "scottmelhop"
      "org_member"     = "admin"
    }

    "ivan.surif@cognitedata.com" = {
      "github_account" = "ivansurif"
      "org_member"     = "member"
    }

    "igor.suchilov@cognitedata.com" = {
      "github_account" = "igors-cognite"
      "org_member"     = "member"
    }
  }
}