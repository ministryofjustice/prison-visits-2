# Prisons using VSiP for visit management

Prior to VSiP, for PVB visit session availability was determined by the environment variables
in [Time Slots using NOMIS](docs/nomis_time_slots.md).

For prisons where VSiP is being used for visit management, indicated by their presence on the
vsip orchestration end point **/config/prison/supported**, timeslots are sourced from the vsip orchestration end
**/visit-sessions** for the specified prison and prisoner.  No filtering logic is applied in PVB, all
related business logic for capacity, non-association, etc. is outside the concern of PVB and remains in
VSiP.

If the prison is not using VSiP for visit management the previous determination of visit sessions is used.

There are 3 environment variables which control the api presented by VSiP, detailed in 
[Configurtion Documentation](https://github.com/ministryofjustice/prison-visits-2/blob/main/docs/configuration.md#staff_prisons_with_slot_availability):

- `VSIP_OAUTH_CLIENT_ID`
- `VSIP_OAUTH_CLIENT_SECRET`
- `VSIP_HOST`
