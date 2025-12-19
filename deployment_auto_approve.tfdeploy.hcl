deployment_auto_approve "development_changes_can_be_auto_approved" {

  check {
    condition = context.plan.changes.remove == 0
    reason    = "Resource removal requires manual approval."
  }

}

deployment_group "development" {
  auto_approve_checks = [
    "development_changes_can_be_auto_approved",
  ]
}