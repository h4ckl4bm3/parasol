require 'rails_helper'

RSpec.describe 'admin/posts/edit', type: :view do
  before(:each) do
    @post = assign(:post, create(:post))
  end

  it 'renders the edit admin/post form' do
    render

    assert_select 'form[action=?][method=?]', admin_post_path(@post), 'post' do
    end
  end
end
