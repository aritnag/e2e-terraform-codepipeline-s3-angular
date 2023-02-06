data "aws_iam_policy_document" "notif_access" {
  statement {
    actions = ["sns:Publish"]

    principals {
      type        = "Service"
      identifiers = ["codestar-notifications.amazonaws.com", "codebuild.amazonaws.com", "codecommit.amazonaws.com", "codepipeline.amazonaws.com"]
    }

    resources = [var.lambdanotifications.arn]
  }
}

resource "aws_sns_topic_policy" "default" {
  arn    = var.lambdanotifications.arn
  policy = data.aws_iam_policy_document.notif_access.json
}

resource "aws_codestarnotifications_notification_rule" "code_commits" {
  detail_type = "BASIC"
  event_type_ids = [
    "codecommit-repository-comments-on-commits",
    "codecommit-repository-comments-on-pull-requests",
    "codecommit-repository-approvals-status-changed",
    "codecommit-repository-approvals-rule-override",
    "codecommit-repository-pull-request-created",
    "codecommit-repository-pull-request-source-updated",
    "codecommit-repository-pull-request-status-changed",
    "codecommit-repository-pull-request-merged",
    "codecommit-repository-branches-and-tags-created",
    "codecommit-repository-branches-and-tags-deleted",
  "codecommit-repository-branches-and-tags-updated"]

  name     = "tf-code_commits-notifications"
  resource = data.aws_codecommit_repository.code_commit_repo.arn

  target {
    address = var.lambdanotifications.arn
  }
}

resource "aws_codestarnotifications_notification_rule" "code_build" {
  detail_type = "BASIC"
  event_type_ids = [
  "codebuild-project-build-state-failed", "codebuild-project-build-state-succeeded", "codebuild-project-build-state-in-progress"]

  name     = "tf-code-build-s3_upload-notifications"
  resource = var.codebuild_s3_upload.arn

  target {
    address = var.lambdanotifications.arn
  }
}

resource "aws_codestarnotifications_notification_rule" "code_build_invalidations" {
  detail_type = "BASIC"
  event_type_ids = [
  "codebuild-project-build-state-failed", "codebuild-project-build-state-succeeded", "codebuild-project-build-state-in-progress"]

  name     = "tf-code-build-cache_invalidation-notifications"
  resource = var.codebuild_cache_invalidation.arn

  target {
    address = var.lambdanotifications.arn
  }
}

resource "aws_codestarnotifications_notification_rule" "code_pipeline" {
  detail_type = "BASIC"
  event_type_ids = [
    "codepipeline-pipeline-action-execution-succeeded",
    "codepipeline-pipeline-action-execution-started",
  "codepipeline-pipeline-pipeline-execution-started", "codepipeline-pipeline-pipeline-execution-succeeded"]

  name     = "tf-code-pipeline-notifications"
  resource = aws_codepipeline.codepipeline.arn

  target {
    address = var.lambdanotifications.arn
  }
}
