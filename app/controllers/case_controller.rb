class CaseController < ApplicationController
  def open

    @cases = Person.all.page(1).per(10).each
    @page = 1
  end

end
