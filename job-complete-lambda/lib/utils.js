/**
 * Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *  SPDX-License-Identifier: Apache-2.0
 */
 const AWS = require('aws-sdk');
 const axios = require('axios')
 axios.defaults.headers.common = {
   "Authorization": process.env.NOTIFICATION_AUTH_HEADER,
   "Content-Type": "application/json"
 }
 /**
  * Ge the Job details from MediaConvert and process the MediaConvert output details
  * from Cloudwatch
  */
 const getJobDetails = async (endpoint,cloudfrontUrl,data) => {
     console.log('Processing MediaConvert outputs');
     const mediaconvert = new AWS.MediaConvert({ endpoint: endpoint });
     let jobDetails = {};
 
     try {
       const result = await mediaconvert.getJob({ Id: data.detail.jobId }).promise();
       jobDetails = result.Job;
     } catch (err) {
         throw err;
     }
      console.log(`JOB DETAILS:: ${JSON.stringify(jobDetails, null, 2)}`);
     return jobDetails;
 };
 
 const getCloudFrontUrls = (cloudfrontUrl,data) => {
   const buildUrl = (originalValue) => originalValue.slice(5).split('/').splice(1).join('/');
   const cfUrls = {
     outputs: {
       HLS_GROUP: [],
       DASH_ISO_GROUP: [],
       CMAF_GROUP: [],
       MS_SMOOTH_GROUP: [],
       FILE_GROUP: [],
       THUMB_NAILS: []
     }
   };
   /**
    * Parse MediaConvert Output and generate CloudFront URLS.
    */
   data.detail.outputGroupDetails.forEach(output => {
     if (output.type != 'FILE_GROUP') {
       cfUrls.outputs[output.type].push(`https://${cloudfrontUrl}/${buildUrl(output.playlistFilePaths[0])}`);
     } else {
       if (output.outputDetails[0].outputFilePaths[0].split('.').pop() === 'jpg') {
         cfUrls.outputs.THUMB_NAILS.push(`https://${cloudfrontUrl}/${buildUrl(output.outputDetails[0].outputFilePaths[0])}`);
       } else {
         output.outputDetails.forEach(filePath => {
           cfUrls.outputs.FILE_GROUP.push(`https://${cloudfrontUrl}/${buildUrl( filePath.outputFilePaths[0])}`);
         });
       }
     }
   });
 
   /**
    * Cleanup any empty output groups
    */
   for (const output in cfUrls.Outputs) {
     if (cfUrls.Outputs[output] < 1) delete cfUrls.Outputs[output];
   }
   return cfUrls;
 }
 
 const sendNotification = async (url, msg) => {
     console.log('Sending notification: ', msg);
     
     try {
     const res = await axios.post(url, { msg: msg });
     console.log(`statusCode: ${res.statusCode}`);
     console.log(res);
     } catch(error) {
         console.log('axios error: ');
         console.error(error)
     }
 };
 
 const deleteSourceFile = async (filePath) => {
     console.log(`Deleting source file: ${filePath}`);
 
     const pathGroups = filePath.match('s3:\/\/(.+?)\/(.+)');
     const params = {Bucket: pathGroups[1], Key: pathGroups[2]};
 
     const result = await new Promise((resolve) => new AWS.S3().deleteObject(params, resolve));
     console.log(JSON.stringify(result));
 };
 
 module.exports = {
     getJobDetails:getJobDetails,
     getCloudFrontUrls:getCloudFrontUrls,
     sendNotification:sendNotification,
     deleteSourceFile:deleteSourceFile
 };
 