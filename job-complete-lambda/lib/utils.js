/**
 * Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *  SPDX-License-Identifier: Apache-2.0
 */
const AWS = require('aws-sdk');
const axios = require('axios')

/**
 * Ge the Job details from MediaConvert and process the MediaConvert output details
 * from Cloudwatch
*/
const processJobDetails = async (endpoint,cloudfrontUrl,data) => {
    console.log('Processing MediaConvert outputs');
    const buildUrl = (originalValue) => originalValue.slice(5).split('/').splice(1).join('/');
    const mediaconvert = new AWS.MediaConvert({
        endpoint: endpoint
    });
    let jobDetails = {};

    try {
        const jobData = await mediaconvert.getJob({ Id: data.detail.jobId }).promise();

        jobDetails = {
            Id:data.detail.jobId,
            Job:jobData.Job,
            OutputGroupDetails: data.detail.outputGroupDetails,
            Outputs: {
                HLS_GROUP:[],
                DASH_ISO_GROUP:[],
                CMAF_GROUP:[],
                MS_SMOOTH_GROUP:[],
                FILE_GROUP:[],
                THUMB_NAILS:[]
            }
        };
        /**
         * Parse MediaConvert Output and generate CloudFront URLS.
        */
       data.detail.outputGroupDetails.forEach(output => {
        if (output.type != 'FILE_GROUP') {
            jobDetails.Outputs[output.type].push(`https://${cloudfrontUrl}/${buildUrl(output.playlistFilePaths[0])}`);
        } else {
            if (output.outputDetails[0].outputFilePaths[0].split('.').pop() === 'jpg') {
                jobDetails.Outputs.THUMB_NAILS.push(`https://${cloudfrontUrl}/${buildUrl(output.outputDetails[0].outputFilePaths[0])}`);
            } else {
                output.outputDetails.forEach(filePath => {
                    jobDetails.Outputs.FILE_GROUP.push(`https://${cloudfrontUrl}/${buildUrl( filePath.outputFilePaths[0])}`);
                });
            }
        }
    });
    /**
     * Cleanup any empty output groups
     */
    for (const output in jobDetails.Outputs) {
        if (jobDetails.Outputs[output] < 1) delete jobDetails.Outputs[output];
    }
    } catch (err) {
        throw err;
    }
     console.log(`JOB DETAILS:: ${JSON.stringify(jobDetails, null, 2)}`);
    return jobDetails;
};

const sendNotification = async (url, msg) => {
    console.log(`Sending notification: ${msg}`);

    await axios.post(url, {
        msg: msg
    })
    .then(res => {
        console.log(`statusCode: ${res.statusCode}`)
        console.log(res)
    })
    .catch(error => {
        console.error(error)
    })
};

const deleteSourceFile = async (filePath) => {
    console.log(`Deleting source file: ${filePath}`);

    const pathGroups = filePath.match('s3:\/\/(.+?)\/(.+)');
    const params = {Bucket: pathGroups[1], Key: pathGroups[2]};

    const result = await new Promise((resolve) => new AWS.S3().deleteObject(params, resolve));
    console.log(JSON.stringify(result));
};

module.exports = {
    processJobDetails:processJobDetails,
    sendNotification:sendNotification,
    deleteSourceFile:deleteSourceFile
};