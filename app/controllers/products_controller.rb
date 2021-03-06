class ProductsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:new, :show, :update, :edit, :message]

  def index
    @liked_products = current_user.get_up_voted(Product)
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      redirect_to root_path
    else
      render :new
    end
  end

  def message
    @product = Product.find(session[:new_product_id])
  end


  def show
    @product = Product.find(params[:id])
    if current_user != nil
      @liked_products = current_user.get_up_voted(Product)
    end
    if @product.prod_add != nil
      JSON[@product.prod_add].each do |additive|
      if additive.length <= 7
          additive_adj = additive[3..6].capitalize
      elsif additive.length > 7
          additive_adj = (additive[3..6].capitalize)+(additive[7..(additive.length+1)])
      end


          
        if Additive.find_by_chemical(additive_adj) == nil
          @risk = nil
        else
          @risk = Additive.find_by_chemical(additive_adj).risk
        end
      end
    end
  end

  def edit
    params[:id] = session[:new_product_id]
    @product = Product.find(params[:id])
  end

  def update

    @product = Product.find(params[:id])
    @product.update(product_params)
    if @product.save
      redirect_to product_path(@product)
    else
      redirect_to root_path
    end
  end

  # def destroy
  #   # authorize @product
  #   @product = Product.find(params[:id])
  #   if @product.destroy
  #     redirect_to root_path
  #   else
  #     redirect_to root_path
  #   end
  # end

  def upvote
    @product = Product.find(params[:id])
    @product.upvote_by current_user
    redirect_to product_path(@product)
  end

  def downvote
    @product = Product.find(params[:id])
    @product.downvote_by current_user
    redirect_to product_path(@product)
  end


  private

  # def requests
  #   @requests = Product.requests
  # end

  # def check_if_admin
  #   if not current_user.admin
  #     redirect_to root_path
  #   end
  # end

  def product_params
    params.require(:product).permit(:name, :sku, :photo, :status, :response, :nutritional_info, :prod_add, :brand, :nutrition_grade, :organic)
  end
end
