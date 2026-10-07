import logging, json, os
import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    logger.info("Lambda invoked with event: %s", json.dumps(event))
    ecr = boto3.client("ecr", region_name=os.getenv("AWS_REGION"))
    try:
        repositories = []
        paginator = ecr.get_paginator("describe_repositories")
        for page in paginator.paginate():
            repositories.extend(page.get("repositories", []))
        logger.info("Found %d repositories", len(repositories))
        for repo in repositories:
            repo_name = repo.get("repositoryName")
            list_images_paginator = ecr.get_paginator("list_images")
            for page in list_images_paginator.paginate(repositoryName=repo_name):
                image_ids = page.get("imageIds", [])
                logger.info("Repository %s has %d images", repo_name, len(image_ids))
                # Placeholder for indexing logic
                # e.g., call soci snapshot or other services
    except Exception as e:
        logger.exception("Error indexing ECR images: %s", str(e))
        raise

    return {"status": "completed"}
