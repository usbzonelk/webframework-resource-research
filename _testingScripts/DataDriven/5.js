import http from 'k6/http';
import { check, sleep } from 'k6';
import { randomIntBetween } from 'https://jslib.k6.io/k6-utils/1.4.0/index.js';
import { Trend } from 'k6/metrics';

// Define server configurations
const servers = [
    { name: 'Express', port: 55001 },
    { name: 'Dotnet', port: 55011 },
    { name: 'Laravel', port: 55021 },
    { name: 'Go', port: 55031 },
    { name: 'Phoenix', port: 55041 },
];

// Define load test ramp-up
const vuCounts = [1, 20, 100, 500, 2000, 10000, 20000];

// Request duration metric
const requestDuration = new Trend('request_duration', true);

// Author emails
const authors = [
    "Spinka4022@blog.com",
    "Huels4023@blog.com",
    "Dickens4024@blog.com",
    "Quitzon4025@blog.com",
    "Schulist4026@blog.com",
    "Kunde4027@blog.com",
    "Yundt4028@blog.com",
    "Daniel4029@blog.com",
    "Kulas4030@blog.com",
    "Hintz4031@blog.com",
    "Torphy4032@blog.com",
    "Brown4033@blog.com",
    "Shanahan4034@blog.com",
    "Glover4035@blog.com",
    "Kulas4036@blog.com",
    "Bridget4037@blog.com",
    "Kunze4038@blog.com",
];

// Function to get a random selection of 1-5 authors
function getRandomAuthors() {
    /*const numberOfAuthors = randomIntBetween(5, 10);
    return authors.sort(() => Math.random() - 0.5).slice(0, numberOfAuthors);*/
    return [authors[5], authors[10]];
}

// Command-line options
const selectedServer = __ENV.SERVER || 'ALL';
const cooldownTime = __ENV.COOLDOWN ? parseInt(__ENV.COOLDOWN, 10) : 5;
const autoContinue = __ENV.AUTO_CONTINUE === 'true';
const vucount = __ENV.VU && parseInt(__ENV.VU) && (parseInt(__ENV.VU) >= 0 && parseInt(__ENV.VU) < vuCounts.length) && Number.isInteger(vuCounts[parseInt(__ENV.VU)]) 
           ? vuCounts[parseInt(__ENV.VU)] : vuCounts[0];
export default function () {
    const serversToTest = selectedServer.toUpperCase() === 'ALL'
        ? servers
        : servers.filter((server) => server.name.toLowerCase() === selectedServer.toLowerCase());

    if (serversToTest.length === 0) {
        console.error(`Error: No matching server found for '${selectedServer}'.`);
        return;
    }

    for (let i = 0; i < serversToTest.length; i++) {
        const { name, port } = serversToTest[i];
        const url = `http://localhost:${port}/authors/get-posts`;

 

        let moveToNextServer = false;

        for (let vu of vuCounts) {
            if (!autoContinue && vucount) {
                vu = vucount;
            }
            if (moveToNextServer) break;

 

            for (let j = 0; j < vu; j++) {
                const payload = JSON.stringify({ emails: getRandomAuthors() });
                const params = { headers: { 'Content-Type': 'application/json' } };
                const startTime = Date.now();
                const response = http.post(url, payload, params, { timeout: "9999999s" });
                const endTime = Date.now();
                requestDuration.add(endTime - startTime);

                check(response, { 'status is 2xx': (r) => r.status >= 200 && r.status < 300 });

                if (response.status >= 400) {
                    console.warn(`⚠️ Request failed for ${name} on port ${port} at ${vu} users: Status ${response.status}`);
                    moveToNextServer = true;
                    break;
                }
            }

            if (moveToNextServer) {
                console.log(`Stopping benchmark for ${name} on port ${port}: Failed at ${vu} users. Moving to next server.\n`);
                break;
            }

             if (!autoContinue) {
                 return;
            }

 
        }

 
        sleep(1);
    }
}
