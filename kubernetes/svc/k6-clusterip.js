import http from 'k6/http';

export const options = {
  vus: 2, //virtual users run concurrently
  iterations: 100, // number of requests throughtout the test
  duration: '10s', //duration of the test execution
  noConnectionReuse: true, // disable keep-alive connections
};

export default function () {
  http.get('http://web01:8080');
}
