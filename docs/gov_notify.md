# Gov Notify

Due to the COVID-19 pandemic the prison visits application was turned off for around 2 years, and over that time
MoJ stopped making payments to the previous emailing application. In general most government services should be using GovNotify to send notifications to their users.

As part of spinning up the existing application we had to migrate the emailing capabilities to GovNotify, in order to align with the standard way to send notifications for a
government service. 

[Here](https://docs.notifications.service.gov.uk/ruby.html) is the documentation for using GovNotify for a ruby application.

I created a new service called [gov_notify_emailer.rb](https://github.com/ministryofjustice/prison-visits-2/blob/face8b54ad7d380ce4a18c6573fd0395a44499cb/app/services/gov_notify_emailer.rb), which deals with the sending of notifications,
as well as the formatting of the notification itself. (***There is a branch called `refactor_mailer` which refactors out the email formatting logic into a presenter***).


We send an email notification to a user on 5 different events:

- When a booking request has been acknowledged [Code extract](https://github.com/ministryofjustice/prison-visits-2/blob/7999d511f6efc6926725b58473f8842a47b5c7f0/app/mailers/visitor_mailer.rb#L13)
- When a booking request has been accepted [Code extract](https://github.com/ministryofjustice/prison-visits-2/blob/7999d511f6efc6926725b58473f8842a47b5c7f0/app/services/booking_responder/accept.rb#L9)
- When a booking request has been rejected [Code extract](https://github.com/ministryofjustice/prison-visits-2/blob/7999d511f6efc6926725b58473f8842a47b5c7f0/app/services/booking_responder/reject.rb#L14)
- When a booking request has been cancelled [Code extract](https://github.com/ministryofjustice/prison-visits-2/blob/7999d511f6efc6926725b58473f8842a47b5c7f0/app/services/booking_responder/cancel.rb#L11)
- When sending a one off message [Code extract](https://github.com/ministryofjustice/prison-visits-2/blob/7999d511f6efc6926725b58473f8842a47b5c7f0/app/models/message.rb#L15)

***Note: I kept the existing references to the old mailer, as some elements are tightly coupled to the existing mailer. In addition this system will soon be replaced with a new booking service, so this system just needs to exist and operate in a low maintenance mode.***

To access the GovNotify templates and settings visit the [GovNotify site](https://www.notifications.service.gov.uk/) and select the service `Book a prison visit`, if you need access to the service  please contact either
`paul.solecki@digital.justice.gov.uk` or `phoebe.crossland@digital.justice.gov.uk`
