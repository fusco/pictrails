class Admin::PicturesController < Admin::BaseController
  
  cache_sweeper :picture_sweeper,  :only => [:create, :update, :destroy]

  # See all pictures
  def index
    @pictures = Picture.find :all
  end

  # View the Picture when your are logged
  def show
    @picture = Picture.find params[:id]
  rescue ActiveRecord::RecordNotFound
    render :status => 404
  end

  # View the form to edit the picture
  def edit
    @picture = Picture.find params[:id]
  rescue ActiveRecord::RecordNotFound
    render :status => 404
  end
  
  # View a form to add a new picture in a gallery
  def new
    @picture = Picture.new
    @picture.status = true
    @picture.gallery_id = params[:gallery_id]
    @gallery = Gallery.find params[:gallery_id]

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @picture }
    end
  end

  # Update the Picture
  def update
    @picture = Picture.find params[:id]
    @picture.title = params[:picture][:title]
    @picture.description = params[:picture][:description]
    @picture.status = params[:picture][:status]
    if @picture.save
      flash[:notice] = 'Picture Updated'
      redirect_to admin_gallery_picture_url(@picture.gallery, @picture)
    else
      define_gallery
      render :action => 'edit'
    end
  end
  
  # Create a picture in a Gallery
  def create
    @picture = Picture.new(params[:picture])
    
    respond_to do |format|
      if @picture.save
        flash[:notice] = 'Picture was successfully created.'
        format.html { redirect_to(admin_gallery_picture_url(params[:gallery_id], @picture)) }
        format.xml  { render :xml => @picture, :status => :created, :location => @picture }
      else
        define_gallery
        format.html { render :action => "new" }
        format.xml  { render :xml => @picture.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # Destroy the picture of a gallery
  def destroy
    @picture = Picture.find(params[:id])
    @picture.destroy
    flash[:notice] = "Picture #{@picture.title} is deleted"

    respond_to do |format|
      format.html { redirect_to(edit_admin_gallery_url(params[:gallery_id])) }
      format.xml  { head :ok }
    end
  end

private

  def define_gallery
    @gallery = Gallery.find(params[:gallery_id]) if params[:gallery_id]
  end

end
