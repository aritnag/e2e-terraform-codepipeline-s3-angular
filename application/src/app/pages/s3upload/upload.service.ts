
import { Injectable } from '@angular/core';
import { PutObjectCommand, S3Client  } from "@aws-sdk/client-s3";
import { fromCognitoIdentityPool } from "@aws-sdk/credential-providers";

@Injectable()
export class UploadFileService {

    FOLDER = 'test/';
    COGNITO_POOL_ID = "<COGNITO_POOL_ID>";
    UPLOAD_BUCKET_ID = '<UPLOAD_BUCKET_ID>';
    constructor() { }

    uploadfile(file: any) {
        
       
        const s3Client = new S3Client({
             region: "eu-west-1",
             credentials:fromCognitoIdentityPool({
                identityPoolId:this.COGNITO_POOL_ID,
                clientConfig:{region:"eu-west-1"}
             }),
             
            });
        const bucketParams = {
            Bucket: this.UPLOAD_BUCKET_ID,
            Key: this.FOLDER + file.name,
            Body: file,
        }
        const command = new PutObjectCommand(bucketParams);
        s3Client.send(command).then(
            (data) => {
            },
            (error) => {
            }
          );

    }
}