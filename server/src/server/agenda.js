const Agenda = require('agenda');
const axios = require('axios');
const {MONGOURI} = require("./config/db.js");

const agenda = new Agenda({
    db: {
        address: MONGOURI,
        options: {
            useNewUrlParser: true,
            useUnifiedTopology: true,
        }
    }
});

agenda.define('start event', {}, async job => {
    const event = job.attrs.data;

    let config = {
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'api_token': process.env.API_TOKEN
        }
    };
    axios.post('http://localhost:8080/api/food/addEvent', event, config)
        .then(function () {
            console.log('added event', event.eventTitle);
        })
        .catch(function (error) {
            console.log(error);
        });
    if (event.repetition === 'Repetition.none') {
        axios.delete('http://localhost:8080/api/future/' + event._id.toString(), config)
            .then(function () {
                console.log('deleted event', event.eventTitle);
            })
            .catch(function (error) {
                console.log(error);
            });
    }
});

agenda.define('end event', {}, async job => {
    console.log('scheduling end event');
    const event = job.attrs.data;
    let markedInactive = event.isActive;
    let author = event.emailId;

    if (!markedInactive.includes(author)) {
        markedInactive.push(author);
        event.isActive = markedInactive;
        event.eventId = event._id;

        let config = {
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
                'api_token': process.env.API_TOKEN
            }
        };
        axios.post('http://localhost:8080/api/food/updateEvent', event, config)
            .then(function () {
                console.log('marked event as invalid', event.eventTitle);
            })
            .catch(function (error) {
                console.log(error);
            });
    }
});

(async () => {
    await agenda.start();
    await agenda.cancel({nextRunAt: null});
})();

module.exports = agenda;