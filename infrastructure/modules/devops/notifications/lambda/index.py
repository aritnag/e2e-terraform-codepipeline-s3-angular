import os
import json
import boto3

client = boto3.client('sns')


def lambda_handler(event, context):
    print(event)
    for i in event['Records']:

        message = i['Sns']['Message']
        parsed_message = json.loads(message)
        if parsed_message["source"] == "aws.codebuild":
            message,subject = final_status(
                parsed_message["source"],
                parsed_message["detail"]["build-status"],
                parsed_message["detail"]["project-name"],
                parsed_message["time"],
                parsed_message["account"],
                parsed_message["detailType"]
            )
        elif parsed_message["source"] == "aws.codepipeline" :
            message,subject = final_status(
                parsed_message["source"],
                "Code Pipeline Execution Started",
                parsed_message["detail"]["pipeline"],
                parsed_message["time"],
                parsed_message["account"],
                parsed_message["detailType"]
            )
        elif  parsed_message["source"] == "aws.codecommit":
            message,subject = final_status_code_commit(
                "Code Commit Execution Started",
                parsed_message["detail"]["repositoryName"],
                parsed_message["detail"]["referenceFullName"],
                parsed_message["detail"]["commitId"],
                parsed_message["time"],
                parsed_message["account"],
                parsed_message["detailType"]
            )
        client.publish(
            TargetArn=os.environ['sns_topic_arn'],
            Message=message,
            Subject=subject
        )
    return {
        'statusCode': 200,
        'body': "message sent"
    }


def final_status(detail_type, build_status, project_name, time,account,source):
    sub = "[{source}]: Notification".format(source=source)
    msg = """
        Notification Type Details.

        ------------------------------------------------------------------------------------
        Summary of the Notification:
        ------------------------------------------------------------------------------------
        Detail Type    :   {detail_type}
        Build Status    :   {build_status}
        Project Name   :  {project_name}
        Time    :   {time}
        Account    :   {account}
        ------------------------------------------------------------------------------------
        """.format(detail_type=detail_type, build_status=build_status, project_name=project_name, time=time, account=account)
    return msg,sub



def final_status_code_commit(event, repository_name, repository_branch, commit_id,time,account,source):
    sub = "[{source}]: Notification".format(source=source)
    msg = """
        Notification Type Details.

        ------------------------------------------------------------------------------------
        Summary of the Notification:
        ------------------------------------------------------------------------------------
        Event Type    :   {event}
        Repo Name    :   {repository_name}
        Repo Branch   :  {repository_branch}
        Commit Id   :  {commit_id}
        Time    :   {time}
        Account    :   {account}
        ------------------------------------------------------------------------------------
        """.format(event=event, repository_name=repository_name, repository_branch=repository_branch,commit_id=commit_id, time=time, account=account)
    return msg,sub