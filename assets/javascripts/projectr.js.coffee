#= require vendor/jquery-2.0.2.min
#= require vendor/underscore-min.js
#= require vendor/marked.js

Projectr = {
  languageSelector: '#language'
  apiBaseUrl: "https://api.github.com"

  updateIssue: ->
    @_startLoading()
    @_updateRepo() unless @_language() == ''

  _updateRepo: ->
    $.ajax(
      url: @_repoUrl()
      dataType: 'jsonp'
    ).done (response) =>
      repo = _.find response.data.repositories, (repo) ->
        repo.open_issues > 0

      @_updateIssueForRepo(repo)

   _repoUrl: ->
      "#{@apiBaseUrl}/legacy/repos/search/#{@_randomLetter()}?language=#{@_language()}"

   _randomLetter: ->
     letters = "abcdefghijklmnopqrstuvwxyz"
     letters[Math.floor(Math.random() * (letters.length + 1))]

   _updateIssueForRepo: (repo) ->
     $.ajax(
       url: @_issueURL(repo)
       dataType: 'jsonp'
     ).done (response) =>
       issue = _.find response.data, (issue) ->
         issue.pull_request.html_url == null

       if issue
         @_displayIssue(issue)
       else
         @_updateRepo()

   _displayIssue: (issue) ->
     $('#issue').html(_.template($('#issue_template').html(), { issue: issue }))
     @_finishedLoading()

   _issueURL: (repo) ->
     "#{@apiBaseUrl}/repos/#{repo.owner}/#{repo.name}/issues"

   _language: ->
     $(@languageSelector).val()

   _startLoading: ->
     $('.content').addClass('loading')


   _finishedLoading: ->
     $('.content').removeClass('loading')
}


$(document).ready ->
  Projectr.updateIssue()

  $('#language').change ->
    issue    = Projectr.updateIssue()

  $('#new').click ->
    issue    = Projectr.updateIssue()

