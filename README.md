# Tweet Archiver

**Very much in beta**

There are a million of these out there, and this one is mine.

Archives a user's tweets in the same format as the downloadable Twitter archive, and optionally deletes those tweets from timeline.

Right now, this only updates the tweet CSV. To view as a website, you need to update the JSON. I haven't tackled that yet, and may just not.

## Usage

Can be run locally or configured to run regularly with e.g. Heroku Scheduler

Tasks:
* `rake tweet_archivist:archive_through_last_week` to archive all tweets through last week    
* `rake tweet_archivist:archive_through_last_week[with_delete]` to archive and delete all tweets through last week    

## Data Stores

### Amazon S3 Integration - CSV

Upload your tweet archive from Twitter, and then regularly add rows of tweets to the CSV file after archiving.

**To set up,**

* Create an [AWS account](https://aws.amazon.com)
* Create a private S3 bucket and (recommended) [enable versioning](https://docs.aws.amazon.com/AmazonS3/latest/dev/Versioning.html#how-to-enable-disable-versioning-intro)
* Provision an IAM user with programmatic access
* For development, add the credentials for the IAM user to your `.env` file as `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`
* For development, add the S3 bucket name and region to your `.env` file as `AWS_BUCKET_NAME` and `AWS_BUCKET_REGION`

* Download your Twitter tweets archive
* Unzip the tweets archive locally and rename the resulting directory to `tweet_archive`
* Upload the `tweet_archive` directory (including containing folder) to the S3 bucket

* In AWS console, grant IAM user at least 'GetObject', 'PutObject', and 'ListObject' permissions for the tweet_archive directory in the S3 bucket (at least for `tweets.csv`, but also okay to grant permission for all files in directory). Here's my example policy:
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject"
            ],
            "Resource": "arn:aws:s3:::my-s3-bucket/tweet_archive/*"
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": "s3:ListObjects",
            "Resource": "*"
        }
    ]
}
```

---

Potential todos:

* Features:
    * Update JSON so that Tweet archive web interface is usable (right now just updating CSV)
    * Pagination (for archiving more than the last 200 tweets)
    * Additional rake tasks or customization
* Dev work:
    * Integration testing
    * Unit testing for S3 repository
    * Break out CSV creation into own class
