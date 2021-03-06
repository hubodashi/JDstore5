class ProductsController < ApplicationController
 before_action :validate_search_key, only: [:search]
 def index
   @products = Product.where(:is_hidden => false).order("position ASC").paginate(:page => params[:page], :per_page => 5)
  if params[:favorite] == "yes"
     @products = current_user.products.paginate(:page => params[:page], :per_page => 5)
  end
 end
 def show
   @product = Product.find(params[:id])
   @photos = @product.photos.all
   @posts = @product.posts.order("created_at DESC").paginate(:page => params[:page], :per_page => 5)
 end
 def add_to_cart
   @product = Product.find(params[:id])
      if !current_cart.products.include?(@product)
         current_cart.add_product_to_cart(@product)
        flash[:notice] = "你已成功将 #{@product.title} 加入购物车"
      else
        flash[:warning] = "你的购物车内已有此物品"
      end
   redirect_to :back
 end
 def add_to_favorite
  @product = Product.find(params[:id])
  @product.users << current_user
  @product.save
  redirect_to :back, notice:"成功加入收藏!"
end
def quit_favorite
  @product = Product.find(params[:id])
  @product.users.delete(current_user)
  @product.save
  redirect_to :back, alert: "成功取消收藏!"
end
def upvote
  @product = Product.find(params[:id])
  if !current_user.is_voter_of?(@product)
    current_user.like!(@product)
    flash[:notice]= "您已点赞了该商品"
  else
    flash[:warning]= "您已点赞过该商品，无法重复点赞"
  end
  redirect_to :back
end
 # <----------------------制作搜索功能--------------------------------->
 def search
    if @query_string.present?
      search_result = Product.ransack(@search_criteria).result(:distinct => true)
      @products = search_result.paginate(:page => params[:page], :per_page => 5 )
    end
  end


  protected

  def validate_search_key
    @query_string = params[:q].gsub(/\\|\'|\/|\?/, "")
    if params[:q].present?
    @search_criteria = search_criteria(@query_string)
    end
  end


  def search_criteria(query_string)
    { :title_cont => query_string }
  end
  # <------------------------------------------------------------->
  def product_params
    params.require(:product).permit(:title, :description, :quantity, :price, :image, :category_id, :is_hidden)
  end

end
