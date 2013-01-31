require 'sinatra'

class AccountApiApp < ApiBase
  get '/:id.json' do
     # find by login first, then try ID, raising the standard error if not found by id
    account = Account.find_by_login(params[:id]) || Account.find(params[:id])
    account.extend(AccountSummaryRepresenter)
    account.to_json
  end
end
