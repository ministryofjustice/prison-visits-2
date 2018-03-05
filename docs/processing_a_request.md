# Processing a request

The `Prison::VisitsController` is used by prison staff to accept or reject a
visit request. It instantiates a `StaffResponse` object which is responsible
for validating the response. This ensures that a slot or rejection reason is
selected, and that other essential details are present, such as which visitors
are banned when that is the reason for rejection.

When the `StaffResponse` is valid, it is handed to the `BookingResponder`,
which updates the `Visit` record with the new `processing_state` and saves any
other information required.