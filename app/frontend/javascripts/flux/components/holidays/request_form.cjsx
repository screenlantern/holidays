Calendar = require '../calendar/calendar'
moment = require 'moment'
Modal = require '../utils/modal'

RequestForm = React.createClass
  displayName: 'RequestForm'

  componentDidMount: ->
    date = moment().startOf("day").format 'YYYY-MM-DD'
    @app.queries.findForMonth date

  _handleMonthChanged: (month) ->
    @app.queries.findForMonth month.format 'YYYY-MM-DD'

  _renderSelectedDates: ->
    return unless @props.datesValidated

    sortedDates = _.sortBy @props.selectedDates, (n) ->
      n

    dates = sortedDates.map (date, i) ->
      <li key={i}>
        <header>{date.format("MMM")}</header>
        <div className="day">
          <strong>{date.format("DD")}</strong>
        </div>
      </li>

    <div>
      <h5>Selected dates:</h5>
      <ul className="selected-dates">
        {dates}
      </ul>
    </div>

  _showCalendar: ->
    @app.actionCreators.setDatesValidated(false)

  _renderCalendar: ->
    return if @props.datesValidated

    calendarProps =
      selectedDates: @props.selectedDates
      datesChanged: @_handleDatesChanged
      publicHolidays: @props.publicHolidays
      monthChanged: @_handleMonthChanged

    <div key="calendar">
      <h5>Select desired dates:</h5>
      <Calendar {...calendarProps}/>
      <div className="right">
        <a href="#" onClick={@_validateSelectedDates} disabled={@props.selectedDates.length == 0}>Add a comment <i className="fa fa-arrow-right"/></a>
      </div>
    </div>

  _handleDatesChanged: (dates) ->
    @app.actionCreators.setSelectedDates dates

  _validateSelectedDates: (e) ->
    e.preventDefault()
    @app.actionCreators.setDatesValidated @props.selectedDates.length > 0

  _handleCancelClick: (e) ->
    e.preventDefault()
    @_hideForm()

  _hideForm: ->
    @app.actionCreators.hideForm()

  _renderFormInputs: ->
    return unless @props.datesValidated

    <div className="holidays-data-wrapper">
      <h5>Want to add a comment?</h5>
      <textarea ref="message" cols="30" name="" placeholder="Comments..." rows="10"></textarea>
      <br/>
      <a href="#" onClick={@_showCalendar}><i className="fa fa-arrow-left"/> Change dates</a>
    </div>

  _renderActions: ->
    <div className="actions">
      <a href="#" onClick={@_handleCancelClick}>Cancel</a>
      <button className="btn" type="submit" disabled={@props.selectedDates.length == 0}>
        Create request
      </button>
    </div>

  _onSubmit: (e)->
    e.preventDefault()

    return unless @props.selectedDates.length > 0

    message = if @refs.message != undefined then @refs.message.getDOMNode().value.trim() else ''

    requestedDaysAttributes = @props.selectedDates.map (date) ->
      day: date.format 'YYYY-MM-DD'


    vacationRequest =
      message: message
      requested_days_attributes: requestedDaysAttributes

    @app.actionCreators.create vacationRequest

  _renderError: ->
    return unless @props.error

    errors = @props.error.base.map (error, i) ->
      <li key={i}>{error}</li>

    <div className="message error-message">
      <ul>
        {errors}
      </ul>
    </div>

  _handleOnShowClick: (e) ->
    e.preventDefault()
    @app.actionCreators.showForm()

  render: ->
    <div>
      <a onClick={@_handleOnShowClick} className="btn" href="#">Request holidays</a>
      <Modal show={@props.showForm} hide={@_hideForm}>
        <div className="modal">
          <form onSubmit={@_onSubmit}>
            <header>
              <h3>Request holidays</h3>
            </header>
            {@_renderError()}
            <div className="data-wrapper">
              <div className="calendar-wrapper">
                {@_renderCalendar()}
                {@_renderSelectedDates()}
              </div>
              {@_renderFormInputs()}
            </div>
            {@_renderActions()}
          </form>
        </div>
      </Modal>
    </div>

module.exports = Marty.createContainer RequestForm,
  listenTo: [
    'requestFormStore'
    'publicCalendarStore'
  ]

  fetch:
    showForm: ->
      @app.requestFormStore.state.showForm
    selectedDates: ->
      @app.requestFormStore.state.selectedDates
    datesValidated: ->
      @app.requestFormStore.state.datesValidated
    error: ->
      @app.requestFormStore.state.error
    publicHolidays: ->
      @app.publicCalendarStore.getState().publicHolidays

  failed: (errors) ->
    console.log 'Failed rendering RequestForm'
    console.log errors
