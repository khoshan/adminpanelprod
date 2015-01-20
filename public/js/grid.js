/*****************************************************************************
 * PROJECT: template for web-grid farpoint
 *
 * (c) Copyright 2008 SONHG.  All rights reserved.
 *
 * MODULE: grid view 
            resize columns function
            create buttons tools bar
            paging data
 *
 * FILE: 
 *
 * ABSTRACT:
 *
 * $Source: \scripts\grid.js
 * $Revision: 0.1 
 * $Date: 2008/08/06 
 * $Author: SONHG    
 * REVISION HISTORY:
 *
 *****************************************************************************/
(function ($) { // grid view builder
    //
    var docloaded = false;
    $(document).ready(function () {
        docloaded = true
    });
    $.prototype.gridview = function (p) {
        return this.each(function () {
            if (!docloaded) {
                $(this).hide();
                var t = this; $(document).ready(function () { $.add_grid(t, p) })
            } else { $.add_grid(this, p) }
        })
    };
    $.prototype.reload = function (p) {
        return this.each(function () { if (this.grid && this.p.url) this.grid.populate() })
    };
    $.prototype.add_data = function (data) {
        return this.each(function () { if (this.grid) this.grid.data_bind(data) })
    };
    //
    $.add_grid = function (q, p) {
        if (q.grid) return false;
        p = $.extend({ // parameter of grid view
            url: false,
            method: 'POST',
            dataType: 'json',
            autoload: true,
            onError: false,
            onSubmit: false,
            page: 1,
            total: 1,
            rp: 15,
            title: false,
            params: [],
            height: 200,
            width: 'auto'
        }, p);
        $(q).show().attr({
            cellPadding: 0, cellSpacing: 0, border: 0
        }).removeAttr('width');

        var g = {
            data_bind: function (data) {
               
                data = $.extend({ rows: [], page: 0, total: 0 }, data)
                
                $('.reload', this.taskbar).removeClass('loading');
                this.loading = false;
                if (!data) return false;
                
                p.total = data.total
                if (p.total == 0) { // no records
                    $('tr, a, td, div', q).unbind();
                    $(q).empty();
                    p.pages = 1;
                    p.page = 1;
                    this.paging();
                    return false
                }
                p.pages = Math.ceil(p.total / p.rp);

                p.page = data.page
                this.paging();
                var tbody = document.createElement('tbody');
                // data binding
                {
                    $.each(data.rows, function (i, row) {
                        var tr = document.createElement('tr');
                        if (i % 2) { tr.className = 'stripped' }
                        if (row.id) { tr.id = 'row' + row.id }
                        $('thead tr:first th', g.cl_header).each(function () {
                            var td = document.createElement('td');
                            var idx = $(this).attr('axis').substr(3);
                            
                            td.align = this.align;
                            if (typeof row.cell[idx] != "undefined") {
                                td.innerHTML = (row.cell[idx] != null) ? row.cell[idx] : ''
                            } else {
                                td.innerHTML = row.cell[p.cols[idx].name]
                            }
                            $(td).attr('abbr', $(this).attr('abbr'));
                            $(tr).append(td); td = null
                        });

                        if ($('thead', this.mainDiv).length < 1) {
                            for (idx = 0; idx < cell.length; idx++) {
                                var td = document.createElement('td');
                                if (typeof row.cell[idx] != "undefined") {
                                    td.innerHTML = (row.cell[idx] != null) ? row.cell[idx] : ''
                                } else {
                                    td.innerHTML = row.cell[p.cols[idx].name]
                                }
                                $(tr).append(td);
                                td = null
                            }
                        }
                        $(tbody).append(tr);
                        tr = null
                    })
                }
                $('tr', q).unbind();
                $(q).empty();
                $(q).append(tbody);
                this.add_cell();
                this.row_select();
                this.refresh();
                tbody = null;
                data = null;
                i = null;
                this.cl_header.scrollLeft = this.bodyDiv.scrollLeft;
            },
            page_jump: function (ctype) {
                if (this.loading) { return true }
                switch (ctype) {
                    case 'prev': if (p.page > 1) { p.nwp = parseInt(p.page) - 1 } break;
                    case 'next': if (p.page < p.pages) {
                        p.nwp = parseInt(p.page) + 1
                    } break;
                    case 'input': var nv = parseInt($('.pcontrol input', this.taskbar).val());
                        if (isNaN(nv)) { nv = 1 }
                        if (nv < 1) { nv = 1 }
                        else if (nv > p.pages) {
                            nv = p.pages
                        }
                        $('.pcontrol input', this.taskbar).val(nv);
                        p.nwp = nv;
                        break
                }
                if (p.nwp == p.page) { return false } if (p.onChangePage) { p.onChangePage(p.nwp) } else { this.populate() }
            },
            paging: function () {
                $('.pcontrol input', this.taskbar).val(p.page);
                $('.pcontrol span', this.taskbar).html(p.pages);
                var x = (p.page - 1) * p.rp + 1;
                var y = x + p.rp - 1;
                if (p.total < y) {
                    y = p.total;
                }
                if (p.total < x) { x = p.total;}
                $('.pstate', this.taskbar).html('Show ' + x + ' to ' + y + ' of ' + p.total + ' records');
            },
            refresh: function () {
                var left = 0 - this.cl_header.scrollLeft;
                if (this.cl_header.scrollLeft > 0)
                    left -= Math.floor(p.cgwidth / 2);
                $(g.cl_resize).css({ top: g.cl_header.offsetTop + 1 });
                var padd = this.padd;
                $('div', g.cl_resize).hide();
                $('thead tr:first th:visible', this.cl_header).each(
                    function () {
                        var n = $('thead tr:first th:visible', g.cl_header).index(this);
                        var pos = parseInt($('div', this).width());
                        if (left == 0) left -= Math.floor(p.cgwidth / 2);
                        pos = pos + left + padd;
                        if (isNaN(pos)) { pos = 0; }
                        $('div:eq(' + n + ')', g.cl_resize).css({
                            'left': pos + 'px'
                        }).show();
                        left = pos
                    })
            },
            create_height: function (nwh) {
                nwh = false;
                if (!nwh) nwh = $(g.bodyDiv).height();
                var h = $(this.cl_header).height();
                $('div', this.cl_resize).each(function () {
                    $(this).height(nwh + h)
                });                
                $(g.rDiv).css({ height: g.bodyDiv.offsetTop + nwh })
            },
            dragStart: function (e, obj) {
                var nw = $('div', this.cl_resize).index(obj);
                var ow = $('th:visible div:eq(' + nw + ')', this.cl_header).width();
                $(obj).addClass('resize').siblings().hide();
                $(obj).prev().addClass('resize').show();
                this.col_resize_ = {
                    startX: e.pageX,
                    ol: parseInt(obj.style.left),
                    ow: ow,
                    n: nw
                };
                $('body').css('cursor', 'col-resize')
                $('body').noSelect()
            },
            dragMove: function (e) {
                if (this.col_resize_)
                {
                    var n = this.col_resize_.n;
                    var diff = e.pageX - this.col_resize_.startX;
                    var nleft = this.col_resize_.ol + diff;
                    var nw = this.col_resize_.ow + diff;
                    if (nw > 30) {
                        $('div:eq(' + n + ')', this.cl_resize).css('left', nleft);
                        this.col_resize_.nw = nw
                    }
                }                
            },
            dragEnd: function () {
                if (this.col_resize_)
                {
                    var n = this.col_resize_.n;
                    var nw = this.col_resize_.nw;
                    $('th:visible div:eq(' + n + ')', this.cl_header).css('width', nw);
                    $('tr', this.bodyDiv).each(function () {
                        $('td:visible div:eq(' + n + ')', this).css('width', nw)
                    });
                    this.cl_header.scrollLeft = this.bodyDiv.scrollLeft;
                    $('div:eq(' + n + ')', this.cl_resize).siblings().show();
                    $('.dragging', this.cl_resize).removeClass('dragging');
                    this.refresh();
                    this.create_height();
                    this.col_resize_ = false
                    $('body').css('cursor', 'default'); $('body').noSelect(false)
                }                
            },
            scroll: function () {
                this.cl_header.scrollLeft = this.bodyDiv.scrollLeft; this.refresh()
            },
            populate: function () {
                if (this.loading) { return true }
                if (p.onSubmit) { if (!p.onSubmit()) { return false } }
                this.loading = true;
                if (!p.url) { return false }
               
                $('.pstate', this.taskbar).html('please wait ...');
                $('.reload', this.taskbar).addClass('loading');

                if (!p.nwp) { p.nwp = 1 }
                if (p.page > p.pages) { p.page = p.pages }
                var param = [{ name: 'page', value: p.nwp },
                    { name: 'rp', value: p.rp }];
                if (p.params.length) {
                    for (var pi = 0; pi < p.params.length; pi++) {
                        param[param.length] = p.params[pi]
                    }
                }
                // post to server-> get list data
                $.ajax({
                    type: p.method,
                    url: p.url,
                    data: param,
                    dataType: p.dataType,
                    success: function (data) {
                        // JSON.
                        // debug alert(p.url);
                        g.data_bind(data)                        
                    },
                    error: function (XMLHttpRequest, textStatus, err) {
                        try {
                            if (p.onError) p.onError(XMLHttpRequest, textStatus, err)
                        } catch (e) { }
                    }
                })
            },
            add_cell: function () { // cell
                $('tbody tr td', g.bodyDiv).each(function () {
                    var tmp = document.createElement('div');                    
                    var pth = $('th:eq(' + $('td', $(this).parent()).index(this) + ')', g.cl_header).get(0);
                    if (pth != null) {
                        $(tmp).css({ textAlign: pth.align, width: $('div:first', pth)[0].style.width });
                        if (pth.hidden) { $(this).css('display', 'none') }
                    }
                    if (this.innerHTML == '') { this.innerHTML = '&nbsp;';}
                    tmp.innerHTML = this.innerHTML;                    
                    var pid = false;
                    if ($(this).parent()[0].id) { pid = $(this).parent()[0].id.substr(3); }
                    $(this).empty().append(tmp).removeAttr('width')
                })
            },
            row_select: function () {
                $('tbody tr', g.bodyDiv).each(function () {
                    $(this).click(function (e) {
                        var obj = (e.target || e.srcElement);
                        if (obj.href || obj.type) return true;
                        $(this).toggleClass('trSelected');
                    });
                })
            }
        };
        // create  header columns
        thead = document.createElement('thead');
        var tr = document.createElement('tr');
        for (var i = 0; i < p.cols.length; i++) {
            var cl = p.cols[i];
            var th = document.createElement('th');
            th.innerHTML = cl.display;
            if (cl.name) {
                $(th).attr('abbr', cl.name)
            }
            $(th).attr('axis', 'col' + i);
            if (cl.align) {
                th.align = cl.align
            }
            if (cl.width) { $(th).attr('width', cl.width) }
            $(tr).append(th)
        }
        $(thead).append(tr);
        $(q).prepend(thead);
        // Grid construction
        g.mainDiv = document.createElement('div');// grid view
        g.titleDiv = document.createElement('div');// grid title
        g.cl_header = document.createElement('div');// columns header
        g.bodyDiv = document.createElement('div');// body        
        g.rDiv = document.createElement('div');
        g.cl_resize = document.createElement('div');//        
        g.tbar = document.createElement('div');// tools bar       
        g.taskbar = document.createElement('div');// task bar
        // create grid view:
        g.tbl = document.createElement('table');
        g.mainDiv.className = 'gridview';
        if (p.width != 'auto') {
            g.mainDiv.style.width = p.width + 'px'
        }
        $(q).before(g.mainDiv);
        $(g.mainDiv).append(q);
        // create toolbar
        if (p.buttons) {
            g.tbar.className = 'tbar';
            var sub = document.createElement('div');
            sub.className = 'tbarsub';
            for (var i = 0; i < p.buttons.length; i++) {
                var btn = p.buttons[i];
                if (!btn.separator) {
                    var b = document.createElement('div');
                    b.className = 'tbr_btn';// class
                    b.innerHTML = "<div><span>" + btn.name + "</span></div>"; // body of tool bar button
                    b.onpress = btn.onpress;
                    b.name = btn.name;
                    if (btn.onpress) { // event
                        $(b).click(function () { this.onpress(this.name, g.mainDiv) })
                    }
                    $(sub).append(b);
                } else { $(sub).append("<div class='separator'></div>") }
            }
            $(g.tbar).append(sub);
            $(g.mainDiv).prepend(g.tbar)
        }
        g.cl_header.className = 'headerDiv';
        $(q).before(g.cl_header);
        g.tbl.cellPadding = 0;
        g.tbl.cellSpacing = 0;
        $(g.cl_header).append('<div class="headerDivBox"></div>');
        $('div', g.cl_header).append(g.tbl);
        var thead = $("thead:first", q).get(0);
        if (thead) $(g.tbl).append(thead);
        thead = null;
        //  
        $('thead tr:first th', g.cl_header).each(function () {
            var thdiv = document.createElement('div');
            if ($(this).attr('abbr')) {
                $(this).click(function (e) {
                    if (!$(this).hasClass('thOver'))
                        return false;
                    var obj = (e.target || e.srcElement);
                    if (obj.href || obj.type) return true;
                });
            }
            // 
            $(thdiv).css({
                textAlign: this.align,
                width: this.width + 'px'
            });
            thdiv.innerHTML = this.innerHTML;
            $(this).empty().append(thdiv).removeAttr('width');
        });
        // body of grid
        g.bodyDiv.className = 'bodyDiv';
        $(q).before(g.bodyDiv);
        $(g.bodyDiv).css({
            height: p.height + "px"
        }).scroll(function (e) {
            g.scroll()
        }).append(q);

        g.add_cell();
        g.row_select();
        var cdcol = $('thead tr:first th:first', g.cl_header).get(0);
        if (cdcol != null) {
            g.cl_resize.className = 'clresize';
            g.padd = 0;
            g.padd += parseInt($('div', cdcol).css('borderLeftWidth')); // get border size
            g.padd += parseInt($('div', cdcol).css('borderRightWidth'));
            g.padd += parseInt($('div', cdcol).css('paddingLeft'));
            g.padd += parseInt($('div', cdcol).css('paddingRight'));
            g.padd += parseInt($(cdcol).css('borderLeftWidth'));       // 
            g.padd += parseInt($(cdcol).css('borderRightWidth'));
            g.padd += parseInt($(cdcol).css('paddingLeft'));
            g.padd += parseInt($(cdcol).css('paddingRight'));
            // 
            $(g.bodyDiv).before(g.cl_resize);
            var cdheight = $(g.bodyDiv).height();
            var hdheight = $(g.cl_header).height();
            $(g.cl_resize).css({ top: -hdheight + 'px' });
            $('thead tr:first th', g.cl_header).each(function () {
                var cgDiv = document.createElement('div');
                $(g.cl_resize).append(cgDiv);
                if (!p.cgwidth) {
                    p.cgwidth = $(cgDiv).width()
                }
                $(cgDiv).css({ height: cdheight + hdheight }).mousedown(function (e) {// resize column
                    g.dragStart(e, this)
                });
            })
        }

        $('tbody tr:odd', g.bodyDiv).addClass('stripped')      
        {// create page panel
            g.taskbar.className = 'tsk';
            g.taskbar.innerHTML = '<div class="tsk2"></div>';
            $(g.bodyDiv).after(g.taskbar);
            var html = ' <div class="grp"><div class="prv taskbutton"><span></span></div> </div> ' +
                '<div class="separator"></div> <div class="grp"><span class="pcontrol"> Page <input type="text" size="4" value="1" /> of <span> 1 </span></span></div> ' +
                '<div class="separator"></div> <div class="grp"> <div class="nxt taskbutton"><span></span></div></div> <div class="separator"></div>' +
				' <div class="grp"> <div class="reload taskbutton"><span></span></div> </div> <div class="separator"></div>' +
				' <div class="grp"><span class="pstate"></span></div>';
            $('div', g.taskbar).html(html);
            $('.reload', g.taskbar).click(function () {
                g.populate()
            });

            $('.prv', g.taskbar).click(function () {
                g.page_jump('prev')
            });
            $('.nxt', g.taskbar).click(function () {
                g.page_jump('next')
            });
            $('.pcontrol input', g.taskbar).keydown(function (e) {
                if (e.keyCode == 13) g.page_jump('input')
            });
        }
        // add title       
        if (p.title) {
            g.titleDiv.className = 'titleDiv';
            g.titleDiv.innerHTML = '<div>' + p.title + '</div>';
            $(g.mainDiv).prepend(g.titleDiv);
        }
        // column resize
        $(document).mousemove(function (e) {
            g.dragMove(e)
        }).mouseup(function (e) {
            g.dragEnd()
        }).hover(function () { }, function () {
            g.dragEnd()
        });
        g.refresh();
        g.create_height();
        q.p = p;
        q.grid = g;
        if (p.url && p.autoload) { g.populate() } return q
    };
})(jQuery);