require "digest"

class Ebook
  @@fb2_template = Liquid::Template.parse(File.open(File.join(Rails.root, "app", "views", "ebooks", "ebook.fb2.liquid")).read)
  
  def self.dir_from_uri(uri)
    File.join(Rails.public_path, "ebooks", Digest::SHA256.hexdigest(uri))
  end
  
  def self.find_or_create(uri)
    book = new(uri)
    book.convert unless book.exists?
    return book
  end
  
  def initialize(uri)
    @uri = uri
  end
  
  def exists?
   File.exist?(self.class.dir_from_uri(@uri))
  end
  
  def generate_fb2
    FileUtils.mkdir_p(dir)
    File.open(filename("fb2"), "w") do |f| 
      f.write @@fb2_template.render({:title => @title, :authors => @authors, :content => @content,
                                     :first_name => @authors.strip.split(" ").first,
                                     :last_name => @authors.strip.split(" ")[1..-1].join(" ")}.stringify_keys)
    end
  end
  
  def generate_epub
    `/usr/bin/ebook-convert #{filename("fb2")} #{filename("epub")} --no-default-epub-cover`
  end
  
  def generate_mobi
    `/usr/bin/ebook-convert #{filename("fb2")} #{filename("mobi")}`
  end
  
  def convert
    doc = Hpricot(open(@uri).read)
    title_splitted = doc.search("h1.entry-title").inner_text.split(".")
    @title = title_splitted.first.strip
    @authors = title_splitted[1..-1].join(".").strip
    @content = doc.search(".entry-content")
    @content.search("script").remove
    @content = @content.inner_html
    generate_fb2
    generate_epub
    generate_mobi
  end
  
  def dir
    self.class.dir_from_uri(@uri)
  end
  
  def filename(format=nil)
    name = @uri.split("/").compact.last
    name += "." + format if format
    name
    File.join(dir, name)
  end
end